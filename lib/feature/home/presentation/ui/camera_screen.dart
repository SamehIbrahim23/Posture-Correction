import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  late CameraController _controller;
  WebSocketChannel? _channel;
  bool _isStreaming = false;
  int _frameCount = 0;
  double _fps = 0;

  String _serverUrl = 'ws://192.168.1.4:5001';
  Uint8List? _processedFrame;
  bool _showProcessedFrame = false;
  bool _isConnected = false;
  DateTime? _lastFrameTime;
  final _frameBuffer = <Uint8List>[];
  bool _isProcessingFrame = false;
  late FlutterTts _flutterTts;
  String _lastFeedback = '';
  DateTime? _lastFeedbackTime;
  final List<String> _feedbackHistory = [];
  bool _showFeedbackHistory = false;

  // High-performance frame streaming
  bool _isImageStreamActive = false;
  final Queue<Completer<void>> _frameQueue = Queue<Completer<void>>();
  int _droppedFrames = 0;
  int _sentFrames = 0;
  Timer? _fpsTimer;

  // Performance settings
  final int _targetFps = 60;
  final int _maxQueueSize = 1; // Limit queue to prevent memory issues
  final bool _useImageStream = true; // Use image stream instead of takePicture
  final int _compressionQuality = 70; // JPEG compression quality

  // Animation controllers
  late AnimationController _pulseAnimationController;
  late AnimationController _feedbackAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initAnimations();
    _initTts();
    _startFpsMonitoring();
  }

  void _initAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
          parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _feedbackAnimationController, curve: Curves.elasticOut),
    );

    _pulseAnimationController.repeat(reverse: true);
  }

  void _startFpsMonitoring() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isStreaming && mounted) {
        setState(() {
          _fps = _sentFrames.toDouble();
          _sentFrames = 0; // Reset counter
        });
      }
    });
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initCamera() async {
    try {
      final frontCamera = widget.cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller.initialize();
      await _controller.lockCaptureOrientation();
      await _controller.setFocusMode(FocusMode.auto);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    if (message is Uint8List) {
      if (_frameBuffer.length < _maxQueueSize) {
        _frameBuffer.add(message);
        _processNextFrame();
      }
    } else if (message is String) {
      try {
        final data = json.decode(message);
        if (data['type'] == 'feedback') {
          final now = DateTime.now();
          if (_lastFeedback != data['message'] ||
              _lastFeedbackTime == null ||
              now.difference(_lastFeedbackTime!).inSeconds > 5) {
            _lastFeedback = data['message'];
            _lastFeedbackTime = now;
            _feedbackHistory.add(
                '${now.hour}:${now.minute}:${now.second} - ${data['message']}');
            if (_feedbackHistory.length > 5) _feedbackHistory.removeAt(0);

            _flutterTts.speak(data['message']);
            _feedbackAnimationController.forward();

            if (mounted) {
              setState(() {});
              Future.delayed(const Duration(seconds: 5), _clearFeedback);
            }
          }
        }
      } catch (e) {
        debugPrint('Error parsing message: $e');
      }
    }
  }

  Future<void> _toggleStreaming() async {
    if (_isStreaming) {
      await _stopStreaming();
      return;
    }

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_serverUrl),
      );
      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _stopStreaming();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _stopStreaming();
        },
      );

      _isConnected = true;
      _frameCount = 0;
      _sentFrames = 0;
      _droppedFrames = 0;
      _lastFrameTime = DateTime.now();

      setState(() => _isStreaming = true);

      if (_useImageStream) {
        await _startImageStream();
      } else {
        _startLegacyStreamingLoop();
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      setState(() => _isStreaming = false);
    }
  }
// In _CameraScreenState class

// Replace the _processImageFrame method with this optimized version:
// In _CameraScreenState class

// Replace the _processImageFrame method with this optimized version:
  Future<void> _processImageFrame(CameraImage image) async {
    if (!_isStreaming || !_isConnected || _channel == null) return;

    try {
      // Skip if queue is full (drop frames to maintain real-time)
      if (_frameQueue.length >= _maxQueueSize) {
        _droppedFrames++;
        return;
      }

      final completer = Completer<void>();
      _frameQueue.add(completer);

      // Process in a separate isolate or thread
      final stopwatch = Stopwatch()..start();
      Uint8List? bytes;

      if (image.format.group == ImageFormatGroup.jpeg) {
        // Fast path for JPEG
        bytes = Uint8List.fromList(image.planes[0].bytes);
      } else {
        // For other formats, use a faster conversion
        bytes = await _convertToJpegFast(image);
      }

      if (bytes != null && _channel != null && _isStreaming) {
        _channel!.sink.add(bytes);
        _sentFrames++;
      }

      stopwatch.stop();
      if (stopwatch.elapsedMilliseconds > (1000 ~/ _targetFps)) {
        debugPrint(
            'Frame processing took too long: ${stopwatch.elapsedMilliseconds}ms');
      }

      completer.complete();
      _frameQueue.remove(completer);
    } catch (e) {
      debugPrint('Frame processing error: $e');
    }
  }

// Add this new method for faster conversion
  Future<Uint8List?> _convertToJpegFast(CameraImage image) async {
    try {
      // Implement a faster conversion method here
      // For example, using FFmpeg or native platform channels
      // This is a placeholder - implement based on your needs
      return await _controller.takePicture().then((file) => file.readAsBytes());
    } catch (e) {
      debugPrint('Conversion error: $e');
      return null;
    }
  }

// Modify the _startImageStream method
  Future<void> _startImageStream() async {
    if (_isImageStreamActive) return;

    _isImageStreamActive = true;
    _frameQueue.clear();
    _droppedFrames = 0;
    _sentFrames = 0;

    try {
      await _controller.startImageStream((CameraImage image) async {
        // Process frames in a separate microtask to avoid blocking
        await Future.microtask(() => _processImageFrame(image));
      });
    } catch (e) {
      _isImageStreamActive = false;
      debugPrint('Image stream error: $e');
    }
  }

  void _processNextFrame() {
    if (_isProcessingFrame || _frameBuffer.isEmpty) return;

    _isProcessingFrame = true;
    final frame = _frameBuffer.removeAt(0);

    if (mounted) {
      setState(() {
        _processedFrame = frame;
        _isProcessingFrame = false;
      });
    }

    if (_frameBuffer.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _processNextFrame());
    }
  }

  // Legacy streaming approach (fallback)
  Future<void> _startLegacyStreamingLoop() async {
    final targetDelay = (1000 / _targetFps).round();

    while (_isStreaming && mounted && _isConnected) {
      final startTime = DateTime.now();

      try {
        final image = await _controller.takePicture();
        final bytes = await image.readAsBytes();

        if (_isStreaming && _channel != null) {
          _channel!.sink.add(bytes);
          _sentFrames++;
          _frameCount++;
        }

        final processTime = DateTime.now().difference(startTime).inMilliseconds;
        final remainingTime = targetDelay - processTime;

        if (remainingTime > 0) {
          await Future.delayed(Duration(milliseconds: remainingTime));
        }
      } catch (e) {
        debugPrint('Frame capture error: $e');
        await Future.delayed(const Duration(milliseconds: 5));
      }
    }
  }

  Future<void> _stopStreaming() async {
    if (_isImageStreamActive) {
      try {
        await _controller.stopImageStream();
        _isImageStreamActive = false;
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
    }

    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }

    _frameBuffer.clear();
    _frameQueue.clear();

    if (mounted) {
      setState(() {
        _isStreaming = false;
        _isConnected = false;
        _processedFrame = null;
      });
    }
  }

  void _clearFeedback() {
    if (_lastFeedback.isNotEmpty) {
      setState(() {
        _lastFeedback = '';
      });
      _feedbackAnimationController.reverse();
    }
  }

  void _toggleView() {
    if (_processedFrame != null) {
      setState(() => _showProcessedFrame = !_showProcessedFrame);
    }
  }

  void _toggleFeedbackHistory() {
    setState(() => _showFeedbackHistory = !_showFeedbackHistory);
  }

  Widget _buildStatusIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isStreaming ? _pulseAnimation.value : 1.0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected
                  ? Colors.green
                  : _isStreaming
                      ? Colors.orange
                      : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: (_isConnected
                          ? Colors.green
                          : _isStreaming
                              ? Colors.orange
                              : Colors.red)
                      .withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusIndicator(),
              const SizedBox(width: 8),
              Text(
                _isConnected ? 'Connected' : 'Disconnected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow('FPS', _fps.toStringAsFixed(1), Icons.speed),
          _buildStatRow('Target', '$_targetFps FPS', Icons.image_rounded),
          _buildStatRow('Method', _useImageStream ? "Stream" : "Capture",
              Icons.camera_alt),
          _buildStatRow('Queue', '${_frameQueue.length}', Icons.queue),
          if (_droppedFrames > 0)
            _buildStatRow(
                'Dropped', '$_droppedFrames', Icons.warning, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: color ?? Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay() {
    if (_lastFeedback.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 80,
      left: 20,
      right: 20,
      child: ScaleTransition(
        scale: _feedbackAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.9),
                Colors.deepOrange.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _lastFeedback,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    Color? color,
  }) {
    return Expanded(
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                color ?? (isPrimary ? Colors.blue : Colors.grey[800]),
            foregroundColor: Colors.white,
            elevation: isPrimary ? 8 : 4,
            shadowColor: (color ?? Colors.blue).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseAnimationController.stop(); // Stop before dispose
    _feedbackAnimationController.stop();
    _pulseAnimationController.dispose();
    _feedbackAnimationController.dispose();
    _fpsTimer?.cancel();
    _flutterTts.stop();
    _isStreaming = false;
    _isConnected = false;
    _isImageStreamActive = false;
    _channel?.sink.close();
    _channel = null;
    _frameBuffer.clear();
    _frameQueue.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Posture Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isStreaming ? Icons.videocam : Icons.videocam_off,
              color: _isStreaming ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleStreaming,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _toggleFeedbackHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    if (!_showProcessedFrame || _processedFrame == null)
                      CameraPreview(_controller),
                    if (_processedFrame != null && _showProcessedFrame)
                      Expanded(
                        child: Image.memory(
                          _processedFrame!,
                          fit: BoxFit.fill,
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width,
                          gaplessPlayback: true,
                        ),
                      ),
                    _buildFeedbackOverlay(),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: _buildStatsCard(),
                    ),
                    if (_showFeedbackHistory)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          width: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Feedback History',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._feedbackHistory.map((feedback) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      feedback,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildControlButton(
                      label: _isStreaming ? 'STOP' : 'START',
                      icon: _isStreaming ? Icons.stop : Icons.play_arrow,
                      onPressed: _toggleStreaming,
                      isPrimary: true,
                      color: _isStreaming ? Colors.red : Colors.green,
                    ),
                    if (_processedFrame != null)
                      _buildControlButton(
                        label: _showProcessedFrame ? 'CAMERA' : 'AI VIEW',
                        icon: _showProcessedFrame
                            ? Icons.camera_alt
                            : Icons.smart_toy,
                        onPressed: _toggleView,
                        color: Colors.purple,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
