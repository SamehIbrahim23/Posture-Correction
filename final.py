import asyncio
import websockets
import cv2
import numpy as np
from collections import deque
import time
import math as m
import mediapipe as mp
import pyttsx3
import threading
import queue
import json

class FrameProcessor:
    def __init__(self):
        self.frame = None
        self.last_frame_time = time.time()
        self.fps = 0
        self.frame_count = 0
        self.fps_history = deque(maxlen=10)
        self.lock = asyncio.Lock()
        self.websockets = set()

        # MediaPipe pose setup
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            min_detection_confidence=0.5,
            model_complexity=1
        )

        # Posture tracking
        self.TRACKING_SIDE = None
        self.last_feedback = set()
        self.feedback_cooldown = {}
        self.FEEDBACK_COOLDOWN_SECONDS = 5

        # Stage tracking
        self.start_time = time.time()
        self.stage = 1  # 1: Initial countdown, 2: Side detection countdown, 3: Detection
        self.countdown1 = 10
        self.countdown2 = 10
        self.captured_frame = None

        # Text-to-speech setup
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', 200)
        self.engine.setProperty('voice', self.engine.getProperty('voices')[0].id)
        self.speech_queue = queue.Queue()

        threading.Thread(target=self.speech_worker, daemon=True).start()

    def speech_worker(self):
        while True:
            message = self.speech_queue.get()
            if message is None:
                break
            self.engine.say(message)
            self.engine.runAndWait()
            self.speech_queue.task_done()
            time.sleep(2)

    def calculate_angle(self, x1, y1, x2, y2, x3, y3):
        angle = m.degrees(m.atan2(y3 - y2, x3 - x2) - m.atan2(y1 - y2, x1 - x2))
        return abs(angle) if abs(angle) <= 180 else 360 - abs(angle)

    async def speak_feedback(self, issues, websocket):
        current_time = time.time()
        new_messages = []
        for issue in issues:
            last_time = self.feedback_cooldown.get(issue, 0)
            if current_time - last_time >= self.FEEDBACK_COOLDOWN_SECONDS:
                new_messages.append(issue)
                self.feedback_cooldown[issue] = current_time

        if new_messages:
            feedback_message = " and ".join(new_messages)
            for ws in self.websockets:
                try:
                    await ws.send(json.dumps({"type": "feedback", "message": feedback_message}))
                except:
                    pass
            self.speech_queue.put(feedback_message)
        self.last_feedback = set(issues)

    async def process_pose(self, frame, websocket):
        h, w = frame.shape[:2]
        current_time = time.time()
        elapsed = current_time - self.start_time

        if self.stage == 1:
            if elapsed < self.countdown1:
                cv2.putText(frame, f"Starting in: {int(self.countdown1 - elapsed)}s", (10, h - 20),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
            else:
                self.captured_frame = frame.copy()
                self.stage = 2
                self.start_time = current_time
                self.speech_queue.put("Detecting side")

        elif self.stage == 2:
            if elapsed < self.countdown2:
                cv2.putText(frame, f"Detecting side in: {int(self.countdown2 - elapsed)}s", (10, h - 20),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)
            else:
                results = self.pose.process(cv2.cvtColor(self.captured_frame, cv2.COLOR_BGR2RGB))
                if results.pose_landmarks:
                    lm = results.pose_landmarks.landmark
                    nose_x = lm[self.mp_pose.PoseLandmark.NOSE].x
                    left_sh_x = lm[self.mp_pose.PoseLandmark.LEFT_SHOULDER].x
                    right_sh_x = lm[self.mp_pose.PoseLandmark.RIGHT_SHOULDER].x
                    self.TRACKING_SIDE = "LEFT" if abs(nose_x - left_sh_x) > abs(nose_x - right_sh_x) else "RIGHT"
                    self.speech_queue.put(f"Detected {self.TRACKING_SIDE} side")
                else:
                    self.TRACKING_SIDE = "RIGHT"
                    self.speech_queue.put("Could not detect, defaulting to RIGHT")
                self.stage = 3

        elif self.stage == 3 and self.TRACKING_SIDE:
            results = self.pose.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            if results.pose_landmarks:
                lm = results.pose_landmarks.landmark
                p = self.mp_pose.PoseLandmark

                if self.TRACKING_SIDE == "LEFT":
                    shoulder, hip, knee, ear = p.LEFT_SHOULDER, p.LEFT_HIP, p.LEFT_KNEE, p.LEFT_EAR
                else:
                    shoulder, hip, knee, ear = p.RIGHT_SHOULDER, p.RIGHT_HIP, p.RIGHT_KNEE, p.RIGHT_EAR

                sh_x, sh_y = int(lm[shoulder].x * w), int(lm[shoulder].y * h)
                hip_x, hip_y = int(lm[hip].x * w), int(lm[hip].y * h)
                kn_x, kn_y = int(lm[knee].x * w), int(lm[knee].y * h)
                ear_x, ear_y = int(lm[ear].x * w), int(lm[ear].y * h)

                hip_angle = self.calculate_angle(sh_x, sh_y, hip_x, hip_y, kn_x, kn_y)
                neck_angle = self.calculate_angle(sh_x, sh_y - 100, sh_x, sh_y, ear_x, ear_y)

                issues = []
                if not (90 <= hip_angle <= 120):
                    issues.append("Adjust your hip position")
                if not (0 <= neck_angle <= 40):
                    issues.append("Keep your neck straight")

                good_posture = not issues
                if not good_posture:
                    await self.speak_feedback(issues, websocket)

                color = (127, 255, 0) if good_posture else (50, 50, 255)
                cv2.putText(frame, f"Tracking Side: {self.TRACKING_SIDE}", (10, 60),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 255), 2)

                y_pos = 90
                for issue in issues:
                    cv2.putText(frame, issue, (10, y_pos), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 0, 255), 2)
                    y_pos += 30

                for x, y in [(sh_x, sh_y), (hip_x, hip_y), (kn_x, kn_y), (ear_x, ear_y)]:
                    cv2.circle(frame, (x, y), 7, (0, 255, 255), -1)
                cv2.line(frame, (sh_x, sh_y), (hip_x, hip_y), color, 4)
                cv2.line(frame, (hip_x, hip_y), (kn_x, kn_y), color, 4)
                cv2.line(frame, (sh_x, sh_y), (ear_x, ear_y), color, 4)

        return frame

    async def process_frame(self, message, websocket):
        img_array = np.frombuffer(message, dtype=np.uint8)
        frame = cv2.imdecode(img_array, cv2.IMREAD_COLOR)

        now = time.time()
        time_diff = now - self.last_frame_time
        self.last_frame_time = now

        processed_frame = await self.process_pose(frame, websocket)

        self.fps_history.append(1 / time_diff if time_diff > 0 else 0)
        self.fps = sum(self.fps_history) / len(self.fps_history)
        self.frame_count += 1

        cv2.putText(processed_frame, f"{self.fps:.1f}fps", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
        cv2.putText(processed_frame, f"#{self.frame_count}", (10, 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

        _, buffer = cv2.imencode('.jpg', processed_frame)
        await websocket.send(buffer.tobytes())

async def handle_stream(websocket):
    processor = FrameProcessor()
    processor.websockets.add(websocket)
    try:
        async for message in websocket:
            await processor.process_frame(message, websocket)
    finally:
        processor.websockets.remove(websocket)

async def websocket_server():
    async with websockets.serve(
        handle_stream,
        "0.0.0.0",
        5001,
        ping_interval=None,
        ping_timeout=None,
        max_size=16*1024*1024,
        compression=None
    ):
        print("WebSocket server started on ws://0.0.0.0:5001")
        await asyncio.Future()

if __name__ == '__main__':
    try:
        import os
        os.nice(-10)
    except:
        pass

    asyncio.run(websocket_server())
