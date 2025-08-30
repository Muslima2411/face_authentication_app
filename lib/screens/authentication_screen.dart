
// screens/authentication_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/face_authentication_service.dart';
import '../services/camera_service.dart';
import '../models/authentication_result.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  bool _isAuthenticating = false;
  String? _userId;
  String _statusMessage = 'Position your face in the frame';
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.linear),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Authentication'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Authenticating: $_userId',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_isAuthenticating)
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isAuthenticating ? Colors.blue : Colors.blue.shade300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: _buildCameraPreview(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAuthenticating ? Icons.security : Icons.info_outline,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAuthenticating ? null : _startAuthentication,
                      icon: _isAuthenticating 
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.security),
                      label: Text(_isAuthenticating ? 'Authenticating...' : 'Authenticate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = CameraService.instance.controller;
    if (controller == null || !CameraService.instance.isInitialized) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing Camera...'),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        // Authentication overlay
        if (_isAuthenticating)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ScanOverlayPainter(_scanAnimation.value),
              );
            },
          ),
        // Center guide
        Center(
          child: Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isAuthenticating ? Colors.blue : Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _isAuthenticating
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _startAuthentication() async {
    if (_userId == null) return;

    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Analyzing face... Please hold still';
    });

    _scanAnimationController.repeat();

    try {
      final result = await FaceAuthenticationService.instance.authenticate(_userId!);
      
      _scanAnimationController.stop();
      
      setState(() {
        _isAuthenticating = false;
      });

      _handleAuthenticationResult(result);
    } catch (e) {
      _scanAnimationController.stop();
      setState(() {
        _isAuthenticating = false;
        _statusMessage = 'Authentication error occurred';
      });
      _showErrorDialog('Authentication error: $e');
    }
  }

  void _handleAuthenticationResult(AuthenticationResult result) {
    switch (result.status) {
      case AuthStatus.success:
        _showSuccessDialog(result);
        break;
      case AuthStatus.failure:
        _showFailureDialog(result);
        break;
      case AuthStatus.error:
        _showErrorDialog(result.message);
        break;
    }
  }

  void _showSuccessDialog(AuthenticationResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Access Granted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Authentication successful!'),
              SizedBox(height: 10),
              Text('User: ${result.userId}'),
              Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
              Text('Processing Time: ${result.processingTime}ms'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(AuthenticationResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Access Denied'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message),
              SizedBox(height: 10),
              Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
              Text('Processing Time: ${result.processingTime}ms'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Try Again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Authentication Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for scanning animation
class ScanOverlayPainter extends CustomPainter {
  final double progress;

  ScanOverlayPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final scanLineY = center.dy - 125 + (250 * progress);

    // Draw scanning line
    canvas.drawLine(
      Offset(center.dx - 100, scanLineY),
      Offset(center.dx + 100, scanLineY),
      paint,
    );

    // Draw scanning effect
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.0),
          Colors.blue.withOpacity(0.3),
          Colors.blue.withOpacity(0.0),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        center.dx - 100,
        scanLineY - 20,
        200,
        40,
      ));

    canvas.drawRect(
      Rect.fromLTWH(center.dx - 100, scanLineY - 20, 200, 40),
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(ScanOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}