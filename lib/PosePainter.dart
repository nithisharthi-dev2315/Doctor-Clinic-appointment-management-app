import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size displaySize;

  const PosePainter({
    required this.poses,
    required this.imageSize,
    required this.displaySize,
  });

  // All skeleton connections
  static const _connections = [
    // Face
    [PoseLandmarkType.leftEar,      PoseLandmarkType.leftEye],
    [PoseLandmarkType.leftEye,      PoseLandmarkType.nose],
    [PoseLandmarkType.nose,         PoseLandmarkType.rightEye],
    [PoseLandmarkType.rightEye,     PoseLandmarkType.rightEar],
    // Torso
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.rightHip],
    // Left arm
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow,     PoseLandmarkType.leftWrist],
    // Right arm
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow,    PoseLandmarkType.rightWrist],
    // Left leg
    [PoseLandmarkType.leftHip,       PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee,      PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.leftAnkle,     PoseLandmarkType.leftHeel],
    [PoseLandmarkType.leftHeel,      PoseLandmarkType.leftFootIndex],
    // Right leg
    [PoseLandmarkType.rightHip,      PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee,     PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.rightAnkle,    PoseLandmarkType.rightHeel],
    [PoseLandmarkType.rightHeel,     PoseLandmarkType.rightFootIndex],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // BoxFit.contain: compute scale and centering offset
    final double scaleX = displaySize.width  / imageSize.width;
    final double scaleY = displaySize.height / imageSize.height;
    final double scale  = min(scaleX, scaleY);
    final double offX   = (displaySize.width  - imageSize.width  * scale) / 2;
    final double offY   = (displaySize.height - imageSize.height * scale) / 2;

    Offset toScreen(PoseLandmark lm) =>
        Offset(lm.x * scale + offX, lm.y * scale + offY);

    final linePaint = Paint()
      ..color = const Color(0xFFD4FF00).withOpacity(0.85)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFD4FF00)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = const Color(0xFFD4FF00).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final whiteDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      final lms = pose.landmarks;

      // Draw lines
      for (final conn in _connections) {
        final a = lms[conn[0]];
        final b = lms[conn[1]];
        if (a != null && b != null &&
            a.likelihood > 0.4 && b.likelihood > 0.4) {
          canvas.drawLine(toScreen(a), toScreen(b), linePaint);
        }
      }

      // Draw keypoints
      for (final lm in lms.values) {
        if (lm.likelihood > 0.4) {
          final pt = toScreen(lm);
          canvas.drawCircle(pt, 9,  glowPaint);
          canvas.drawCircle(pt, 5,  dotPaint);
          canvas.drawCircle(pt, 2,  whiteDot);
        }
      }
    }
  }

  @override
  bool shouldRepaint(PosePainter old) =>
      old.poses != poses || old.imageSize != imageSize;
}
