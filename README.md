<h1>🧘 Posture Correction System</h1>

A real-time, AI-powered posture monitoring system built to help users maintain good posture, especially in remote work or study environments.<br><br>

---

<h2>📋 Project Overview</h2>

This system uses a Flutter mobile application to stream a user's camera feed to a Python backend, which analyzes posture and provides instant, actionable feedback.<br><br>

The project was developed to address the growing issue of musculoskeletal problems caused by prolonged sitting with poor posture. By offering real-time guidance, the system aims to prevent long-term health issues and improve overall productivity.<br><br>

---

<h2>✨ Key Features</h2>

- <b>Real-time Posture Analysis:</b> Utilizes a high-performance image streaming pipeline to analyze posture in real-time.<br>
- <b>AI-Powered Feedback:</b> The backend server uses a MediaPipe-based pose estimation model to detect key body landmarks.<br>
- <b>Multi-modal Feedback:</b> Provides both visual cues on the screen and spoken feedback via text-to-speech (TTS) to alert the user of posture issues.<br>
- <b>Performance Monitoring:</b> Displays live statistics such as Frames Per Second (FPS) and dropped frames to help users monitor the connection and system performance.<br>
- <b>User-friendly Interface:</b> A clean and modern Flutter UI allows users to easily start and stop the analysis, view different camera feeds, and track their feedback history.<br><br>

---

<h2>🚀 How It Works</h2>

The system operates on a client-server architecture:<br><br>

<b>Client (Flutter App):</b> The mobile application captures a live video feed from the front-facing camera.<br>
<b>Streaming:</b> The app compresses each frame and sends it over a WebSocket connection to the Python backend.<br>
<b>Server (Python Backend):</b> The server receives the raw image data and processes it using the MediaPipe pose estimation model.<br>
<b>Analysis:</b> The server calculates angles of the body (e.g., hip, neck) to determine if the user's posture is correct.<br>
<b>Feedback:</b> Based on the analysis, the server sends a feedback message back to the app via the WebSocket. This message triggers a visual alert and a spoken message from the device's TTS engine.<br><br>

---

<h2>🛠️ Technologies Used</h2>

<b>Client (Flutter)</b><br>

- Flutter: A cross-platform UI toolkit for building the mobile application.<br>
- camera: A Flutter package to access the device's camera.<br>
- web_socket_channel: Used to establish the WebSocket connection for real-time streaming.<br>
- flutter_tts: A text-to-speech plugin for providing voice feedback.<br><br>

<b>Server (Python)</b><br>

- websockets: A library for building the WebSocket server to handle the stream.<br>
- OpenCV (cv2): Used for image decoding and drawing landmarks on the processed frames.<br>
- MediaPipe: Google's library for advanced pose estimation and landmark detection.<br>
- pyttsx3: Used for text-to-speech functionality on the server side (note: the Flutter app also has its own TTS, providing redundancy or different feedback options).<br><br>

---

<h2>📺 Video Demo</h2>

👇 

https://github.com/user-attachments/assets/e2b2e6e2-9bfb-46b8-b19d-1504925e01f2

