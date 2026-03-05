import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'PosturePdfService.dart';

class PoseHomeScreen extends StatefulWidget {
  const PoseHomeScreen({super.key});

  @override
  State<PoseHomeScreen> createState() => _PoseHomeScreenState();
}

class _PoseHomeScreenState extends State<PoseHomeScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  File?       _image;
  Size        _imageSize = Size.zero;
  List<Pose>  _poses     = [];
  PoseInfo?   _poseInfo;
  bool        _isLoading = false;
  bool        _showFeedback = false;

  late AnimationController _feedbackController;
  late AnimationController _skeletonController;
  late Animation<double>   _feedbackSlide;
  late Animation<double>   _feedbackFade;
  late Animation<double>   _skeletonFade;

  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single),
  );

  @override
  void initState() {
    super.initState();

    _feedbackController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _skeletonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _feedbackSlide = Tween<double>(begin: 40, end: 0).animate(
        CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut));
    _feedbackFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut));
    _skeletonFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _skeletonController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _skeletonController.dispose();
    _detector.close();
    super.dispose();
  }

  // ── Pick from Gallery ─────────────────────────────────────────────────────
  Future<void> _pickGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920, maxHeight: 1920, imageQuality: 92,
    );
    if (file == null) return;
    await _processImage(File(file.path));
  }

  // ── Pick from Camera ──────────────────────────────────────────────────────
  Future<void> _pickCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920, maxHeight: 1920, imageQuality: 92,
    );
    if (file == null) return;
    await _processImage(File(file.path));
  }

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _poses = [];
      _poseInfo = null;
      _showFeedback = false;
      _image = imageFile;
    });

    _feedbackController.reset();
    _skeletonController.reset();

    try {
      final bytes = await imageFile.readAsBytes();

      // ✅ REMOVE await here
      ui.decodeImageFromList(bytes, (ui.Image img) {
        setState(() {
          _imageSize = Size(
            img.width.toDouble(),
            img.height.toDouble(),
          );
        });
      });

      final inputImage = InputImage.fromFile(imageFile);
      final poses = await _detector.processImage(inputImage);

      final info = _classifyPose(poses);

      setState(() {
        _poses = poses;
        _poseInfo = info;
        _isLoading = false;
        _showFeedback = true;
      });

      _skeletonController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _feedbackController.forward();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _poseInfo =
            PoseInfo('Error', 'Failed to analyze image', '⚠️');
        _showFeedback = true;
      });

      _feedbackController.forward();
    }
  }
  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Column(
        children: [
          // ── Image area fills most of the screen ───────────────────────────
          Expanded(child: _buildImageArea()),

          // ── Feedback card ─────────────────────────────────────────────────
          _buildFeedbackCard(),

          // ── Bottom navigation bar ─────────────────────────────────────────
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Image Area ────────────────────────────────────────────────────────────
  Widget _buildImageArea() {
    return Container(
      color: Colors.black,
      child: _image == null
          ? _buildPlaceholder()
          : Stack(
        fit: StackFit.expand,
        children: [
          // Actual image
          Image.file(_image!, fit: BoxFit.contain),

          // Skeleton overlay
          if (_poses.isNotEmpty)
            AnimatedBuilder(
              animation: _skeletonFade,
              builder: (_, __) => Opacity(
                opacity: _skeletonFade.value,
                child: LayoutBuilder(builder: (ctx, constraints) {
                  return CustomPaint(
                    painter: PosePainter(
                      poses: _poses,
                      imageSize: _imageSize,
                      displaySize: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Loading spinner
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4FF00),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Analyzing Pose…',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Pose name badge top-left
          if (_poseInfo != null && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              child: AnimatedBuilder(
                animation: _skeletonFade,
                builder: (_, __) => Opacity(
                  opacity: _skeletonFade.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FF00),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4FF00).withOpacity(0.4),
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_poseInfo!.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          _poseInfo!.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4FF00).withOpacity(0.1),
              border: Border.all(
                  color: const Color(0xFFD4FF00).withOpacity(0.4), width: 2),
            ),
            child: const Icon(Icons.person_search_outlined,
                color: Color(0xFFD4FF00), size: 42),
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload a photo to detect your pose',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Supports: Yoga • Fitness • Sports • Dance',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Feedback Card (matches screenshot style) ──────────────────────────────
  Widget _buildFeedbackCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: _showFeedback && _poseInfo != null
          ? AnimatedBuilder(
        animation: _feedbackController,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _feedbackSlide.value),
          child: Opacity(
            opacity: _feedbackFade.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                _poseInfo!.feedback,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      )
          : Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          _isLoading
              ? 'Analyzing your pose…'
              : 'Pick an image to get AI pose feedback',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar (Gallery | Pose | Camera) ──────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 28, top: 12, left: 40, right: 40),
      color: const Color(0xFF111111),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          _BarButton(
            icon: Icons.photo_library_outlined,
            onTap: _isLoading ? null : _pickGallery,
            tooltip: 'Gallery',
          ),

          // Center Pose button (yellow, larger)
          GestureDetector(
            onTap: _isLoading ? null : _pickGallery,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4FF00),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4FF00).withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.accessibility_new,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          // Camera button
          _BarButton(
            icon: Icons.camera_alt_outlined,
            onTap: _isLoading ? null : _pickCamera,
            tooltip: 'Camera',
          ),
        ],
      ),
    );
  }


}
class _BarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _BarButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2A2A2A),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
              )
            ],
          ),
          child: Icon(
            icon,
            color: onTap == null ? Colors.white24 : Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }
}
PoseInfo _classifyPose(List<Pose> poses) {
  if (poses.isEmpty) {
    return PoseInfo('Unknown', 'Could not detect a pose. Try a clearer full-body photo.', '❓');
  }

  final lms = poses[0].landmarks;

  PoseLandmark? get(PoseLandmarkType t) => lms[t];

  final nose       = get(PoseLandmarkType.nose);
  final ls         = get(PoseLandmarkType.leftShoulder);
  final rs         = get(PoseLandmarkType.rightShoulder);
  final lh         = get(PoseLandmarkType.leftHip);
  final rh         = get(PoseLandmarkType.rightHip);
  final lk         = get(PoseLandmarkType.leftKnee);
  final rk         = get(PoseLandmarkType.rightKnee);
  final la         = get(PoseLandmarkType.leftAnkle);
  final ra         = get(PoseLandmarkType.rightAnkle);
  final lw         = get(PoseLandmarkType.leftWrist);
  final rw         = get(PoseLandmarkType.rightWrist);
  final le         = get(PoseLandmarkType.leftElbow);
  final re         = get(PoseLandmarkType.rightElbow);

  if (ls == null || rs == null || lh == null || rh == null) {
    return PoseInfo('Pose Detected', 'Great effort! Keep your body aligned for best results.', '🧍');
  }

  final shoulderY  = (ls.y + rs.y) / 2;
  final hipY       = (lh.y + rh.y) / 2;
  final shoulderX  = (ls.x + rs.x) / 2;
  final hipX       = (lh.x + rh.x) / 2;
  final kneeY      = lk != null && rk != null ? (lk.y + rk.y) / 2 : null;
  final ankleY     = la != null && ra != null ? (la.y + ra.y) / 2 : null;
  final wristY     = lw != null && rw != null ? (lw.y + rw.y) / 2 : null;
  final wristX     = lw != null && rw != null ? (lw.x + rw.x) / 2 : null;
  final elbowY     = le != null && re != null ? (le.y + re.y) / 2 : null;

  final bodyHeight = (shoulderY - (ankleY ?? hipY)).abs();
  final bodyWidth  = (ls.x - rs.x).abs();
  final hipLean    = (shoulderX - hipX).abs();

  // ── Downward Dog: hips highest point, shoulders and ankles lower ──────────
  if (lh != null && rh != null && ls != null && rs != null &&
      la != null && ra != null &&
      hipY < shoulderY - 30 && hipY < (la.y + ra.y) / 2 - 30 &&
      wristY != null && wristY > shoulderY) {
    return PoseInfo(
      'Downward Dog',
      'Perfect! Your Downward Dog pose looks amazing! Great hip elevation and spine lengthening.',
      '🐕',
    );
  }

  // ── Warrior II: arms extended, legs wide apart ───────────────────────────
  if (lw != null && rw != null && lk != null && rk != null &&
      (lw.x - rw.x).abs() > bodyWidth * 1.5 &&
      (lk.x - rk.x).abs() > bodyWidth * 0.8) {
    return PoseInfo(
      'Warrior II',
      'Excellent Warrior II! Your arms are perfectly extended. Hold the strength!',
      '⚔️',
    );
  }

  // ── Tree Pose: one knee raised sideways ──────────────────────────────────
  if (lk != null && rk != null && la != null && ra != null) {
    final kneeDiff = (lk.y - rk.y).abs();
    final ankleDiff = (la.y - ra.y).abs();
    if (kneeDiff > 80 && ankleDiff > 80) {
      return PoseInfo(
        'Tree Pose',
        'Beautiful Tree Pose! Your balance and focus are impressive. Stay rooted!',
        '🌳',
      );
    }
  }

  // ── Warrior I: one leg forward, arms up ──────────────────────────────────
  if (lk != null && rk != null && wristY != null && wristY < shoulderY - 30 &&
      (lk.x - rk.x).abs() > bodyWidth * 0.6) {
    return PoseInfo(
      'Warrior I',
      'Powerful Warrior I stance! Your arms reach high and legs are strong. Keep it up!',
      '🏹',
    );
  }

  // ── Arms Raised / Mountain Pose with arms up ─────────────────────────────
  if (wristY != null && wristY < shoulderY - 60 && elbowY != null && elbowY < shoulderY) {
    return PoseInfo(
      'Arms Raised Pose',
      'Great Arms Raised Pose! Your alignment looks wonderful. Feel the stretch!',
      '🙌',
    );
  }

  // ── Plank: horizontal body, wrists under shoulders ───────────────────────
  if (wristY != null && la != null && ra != null) {
    final horizontalSpread = (shoulderY - hipY).abs();
    if (horizontalSpread < 40 && wristY > shoulderY - 20) {
      return PoseInfo(
        'Plank Pose',
        'Solid Plank Pose! Your core is engaged and body is perfectly straight. Hold strong!',
        '💪',
      );
    }
  }

  // ── Child\'s Pose: hips back, arms forward, head low ─────────────────────
  if (nose != null && hipY != null && wristY != null &&
      nose.y > shoulderY + 30 && wristY < shoulderY + 40 &&
      hipY > shoulderY + 20) {
    return PoseInfo(
      "Child's Pose",
      "Relaxing Child's Pose! Your back looks nicely rounded. Breathe deeply and release.",
      '🧘',
    );
  }

  // ── Sitting Pose ──────────────────────────────────────────────────────────
  if (kneeY != null && (hipY - kneeY).abs() < 60) {
    return PoseInfo(
      'Seated Pose',
      'Nice Seated Pose! Keep your spine tall and shoulders relaxed.',
      '🪑',
    );
  }

  // ── T-Pose / Star: arms wide, legs apart ─────────────────────────────────
  if (lw != null && rw != null && la != null && ra != null &&
      (lw.x - rw.x).abs() > bodyWidth * 2.0 &&
      (la.x - ra.x).abs() > bodyWidth * 0.8) {
    return PoseInfo(
      'Star / T-Pose',
      'Impressive Star Pose! Your body symmetry is excellent. Well balanced!',
      '⭐',
    );
  }

  // ── Standing with lean ────────────────────────────────────────────────────
  if (hipLean > 40) {
    return PoseInfo(
      'Side Bend',
      'Nice Side Bend! Feel the stretch along your side body. Keep breathing!',
      '↔️',
    );
  }

  // ── Default: Standing ────────────────────────────────────────────────────
  if (bodyHeight > 150) {
    return PoseInfo(
      'Mountain Pose',
      'Great Mountain Pose! Stand tall with feet grounded and spine long. Breathe deeply!',
      '🏔️',
    );
  }

  return PoseInfo(
    'Human Pose Detected',
    'Pose detected! Your body position has been analyzed. Try a full-body shot for better results.',
    '🧍',
  );
}
class PoseInfo {
  final String name;
  final String feedback;
  final String emoji;

  PoseInfo(this.name, this.feedback, this.emoji);
}

void main() {
  runApp(const APECSApp());
}

// ═══════════════════════════════════════════════════════════════════════════════
//  THEME & COLORS
// ═══════════════════════════════════════════════════════════════════════════════
const _blue      = Color(0xFF1565C0);
const _lightBlue = Color(0xFF42A5F5);
const _orange    = Color(0xFFF57C00);
const _green     = Color(0xFF2E7D32);
const _red       = Color(0xFFC62828);
const _amber     = Color(0xFFFFA000);
const _bg        = Color(0xFFF5F7FA);
const _card      = Color(0xFFFFFFFF);
const _headerBg  = Color(0xFFE3F2FD);

// ═══════════════════════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class PostureMeasurement {
  final String label;
  final String code;
  final double angleDeg;
  final String status;   // 'good' | 'mild' | 'moderate' | 'severe'
  final String finding;
  const PostureMeasurement({
    required this.label, required this.code,
    required this.angleDeg, required this.status,
    required this.finding,
  });
}

class ExerciseSuggestion {
  final String name;
  final String description;
  final String sets;
  final String reps;
  final String tip;
  final IconData icon;
  const ExerciseSuggestion({
    required this.name, required this.description,
    required this.sets, required this.reps,
    required this.tip, required this.icon,
  });
}

class PostureReport {
  final List<PostureMeasurement> measurements;
  final List<String> problems;
  final List<ExerciseSuggestion> exercises;
  final String overallStatus;
  final String summary;
  const PostureReport({
    required this.measurements, required this.problems,
    required this.exercises, required this.overallStatus,
    required this.summary,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
//  POSTURE ANALYSIS ENGINE  (mimics APECS logic from the PDF)
// ═══════════════════════════════════════════════════════════════════════════════

PostureReport analyzePosture(List<Pose> poses) {
  if (poses.isEmpty) {
    return const PostureReport(
      measurements: [], problems: ['No person detected'],
      exercises: [], overallStatus: 'unknown',
      summary: 'Could not detect a person. Please upload a clear full-body photo.',
    );
  }

  final lms  = poses[0].landmarks;
  PoseLandmark? g(PoseLandmarkType t) => lms[t];

  final nose  = g(PoseLandmarkType.nose);
  final lear  = g(PoseLandmarkType.leftEar);
  final rear  = g(PoseLandmarkType.rightEar);
  final ls    = g(PoseLandmarkType.leftShoulder);
  final rs    = g(PoseLandmarkType.rightShoulder);
  final lh    = g(PoseLandmarkType.leftHip);
  final rh    = g(PoseLandmarkType.rightHip);
  final lk    = g(PoseLandmarkType.leftKnee);
  final rk    = g(PoseLandmarkType.rightKnee);
  final la    = g(PoseLandmarkType.leftAnkle);
  final ra    = g(PoseLandmarkType.rightAnkle);
  final lf    = g(PoseLandmarkType.leftFootIndex);
  final rf    = g(PoseLandmarkType.rightFootIndex);

  final measurements = <PostureMeasurement>[];
  final problems     = <String>[];
  final exercises    = <ExerciseSuggestion>[];

  // ── A1: Body Alignment (overall vertical axis) ───────────────────────────
  double bodyAlignAngle = 0;
  if (nose != null && la != null && ra != null) {
    final ankleX = (la.x + ra.x) / 2;
    final dx = nose.x - ankleX;
    final dy = (nose.y - (la.y + ra.y) / 2).abs();
    bodyAlignAngle = dy > 0 ? (atan2(dx.abs(), dy) * 180 / pi) : 0;
  }
  final a1Status = bodyAlignAngle < 2 ? 'good' : bodyAlignAngle < 5 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'A1', label: 'Body Alignment',
    angleDeg: bodyAlignAngle,
    status: a1Status,
    finding: a1Status == 'good'
        ? 'Body is well aligned vertically'
        : 'Slight lateral body shift detected (${bodyAlignAngle.toStringAsFixed(1)}°)',
  ));
  if (a1Status != 'good') problems.add('Lateral body misalignment');

  // ── A2: Head Tilt ────────────────────────────────────────────────────────
  double headTiltAngle = 0;
  if (lear != null && rear != null) {
    final dx = (rear.x - lear.x).abs();
    final dy = (rear.y - lear.y).abs();
    headTiltAngle = dx > 0 ? (atan2(dy, dx) * 180 / pi) : 0;
  } else if (nose != null && ls != null && rs != null) {
    final shoulderMidX = (ls.x + rs.x) / 2;
    headTiltAngle = (nose.x - shoulderMidX).abs() / 10;
  }
  final a2Status = headTiltAngle < 3 ? 'good' : headTiltAngle < 7 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'A2', label: 'Head Tilt',
    angleDeg: headTiltAngle,
    status: a2Status,
    finding: a2Status == 'good'
        ? 'Head is level and balanced'
        : 'Head tilted ${headTiltAngle.toStringAsFixed(1)}° - may indicate neck tension',
  ));
  if (a2Status != 'good') {
    problems.add('Head tilt detected');
    exercises.add(const ExerciseSuggestion(
      name: 'Neck Side Stretch',
      description: 'Gently tilt your head to each side, holding for 20 seconds.',
      sets: '3', reps: '30 sec hold',
      tip: 'Keep shoulders relaxed and down. Do not force the stretch.',
      icon: Icons.self_improvement,
    ));
  }

  // ── A3: Shoulder Alignment ───────────────────────────────────────────────
  double shoulderAngle = 0;
  if (ls != null && rs != null) {
    final dx = (rs.x - ls.x).abs();
    final dy = (rs.y - ls.y).abs();
    shoulderAngle = dx > 0 ? (atan2(dy, dx) * 180 / pi) : 0;
  }
  final a3Status = shoulderAngle < 3 ? 'good' : shoulderAngle < 6 ? 'mild' : shoulderAngle < 10 ? 'moderate' : 'severe';
  measurements.add(PostureMeasurement(
    code: 'A3', label: 'Shoulder Alignment',
    angleDeg: shoulderAngle,
    status: a3Status,
    finding: a3Status == 'good'
        ? 'Shoulders are level and balanced'
        : 'Shoulder imbalance of ${shoulderAngle.toStringAsFixed(1)}°  one shoulder higher than the other',
  ));
  if (a3Status != 'good') {
    problems.add('Shoulder imbalance');
    exercises.add(const ExerciseSuggestion(
      name: 'Shoulder Blade Squeeze',
      description: 'Squeeze your shoulder blades together and hold. Releases tension and improves posture.',
      sets: '3', reps: '15',
      tip: 'Keep chin tucked and avoid shrugging. Feel the squeeze between blades.',
      icon: Icons.fitness_center,
    ));
  }

  // ── A4: Pelvic Tilt ──────────────────────────────────────────────────────
  double pelvicAngle = 0;
  if (lh != null && rh != null) {
    final dx = (rh.x - lh.x).abs();
    final dy = (rh.y - lh.y).abs();
    pelvicAngle = dx > 0 ? (atan2(dy, dx) * 180 / pi) : 0;
  }
  final a4Status = pelvicAngle < 3 ? 'good' : pelvicAngle < 6 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'A4', label: 'Pelvic Tilt',
    angleDeg: pelvicAngle,
    status: a4Status,
    finding: a4Status == 'good'
        ? 'Pelvis is level and stable'
        : 'Pelvic tilt of ${pelvicAngle.toStringAsFixed(1)}°  may cause lower back strain',
  ));
  if (a4Status != 'good') {
    problems.add('Pelvic tilt / hip imbalance');
    exercises.add(const ExerciseSuggestion(
      name: 'Hip Flexor Stretch',
      description: 'Lunge forward with one knee on the ground, push hips forward gently.',
      sets: '3', reps: '30 sec each side',
      tip: 'Keep upper body upright. Feel the stretch in the front of your hip.',
      icon: Icons.directions_run,
    ));
    exercises.add(const ExerciseSuggestion(
      name: 'Fire Hydrants',
      description: 'On all fours, lift one knee out to the side like a dog at a fire hydrant.',
      sets: '3', reps: '15 each side',
      tip: 'Keep your back flat. Control the movement do not rotate the torso.',
      icon: Icons.sports_gymnastics,
    ));
  }

  // ── A5: Knee Alignment ───────────────────────────────────────────────────
  double kneeAngle = 0;
  if (lk != null && rk != null) {
    final dx = (rk.x - lk.x).abs();
    final dy = (rk.y - lk.y).abs();
    kneeAngle = dx > 0 ? (atan2(dy, dx) * 180 / pi) : 0;
  }
  final a5Status = kneeAngle < 3 ? 'good' : kneeAngle < 6 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'A5', label: 'Knee Alignment',
    angleDeg: kneeAngle,
    status: a5Status,
    finding: a5Status == 'good'
        ? 'Knees are properly aligned'
        : 'Knee misalignment ${kneeAngle.toStringAsFixed(1)}° check for valgus or varus',
  ));
  if (a5Status != 'good') {
    problems.add('Knee misalignment');
    exercises.add(const ExerciseSuggestion(
      name: 'Wall Sit',
      description: 'Slide your back down a wall until thighs are parallel to the ground.',
      sets: '3', reps: '30 to 45 sec hold',
      tip: 'Keep knees above ankles. Push knees outward to activate glutes.',
      icon: Icons.accessibility_new,
    ));
  }

  // ── A6: Feet Alignment ───────────────────────────────────────────────────
  double feetAngle = 0;
  if (lf != null && rf != null && la != null && ra != null) {
    final leftAngle = atan2((lf.y - la.y).abs(), (lf.x - la.x).abs()) * 180 / pi;
    final rightAngle = atan2((rf.y - ra.y).abs(), (rf.x - ra.x).abs()) * 180 / pi;
    feetAngle = (leftAngle + rightAngle) / 2;
  } else if (la != null && ra != null) {
    feetAngle = (atan2((ra.y - la.y).abs(), (ra.x - la.x).abs()) * 180 / pi);
    feetAngle = feetAngle > 20 ? feetAngle - 20 : 0;
  }
  final a6Status = feetAngle < 5 ? 'good' : feetAngle < 10 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'A6', label: 'Feet Alignment',
    angleDeg: feetAngle,
    status: a6Status,
    finding: a6Status == 'good'
        ? 'Feet are properly positioned'
        : 'Foot angle of ${feetAngle.toStringAsFixed(1)}° may indicate pronation or supination',
  ));
  if (a6Status != 'good') {
    problems.add('Foot/ankle misalignment');
  }

  // ── B1: Forward Head Posture (Side) ──────────────────────────────────────
  double forwardHeadAngle = 0;
  if (nose != null && ls != null && rs != null) {
    final shoulderMidX = (ls.x + rs.x) / 2;
    final shoulderMidY = (ls.y + rs.y) / 2;
    final dx = (nose.x - shoulderMidX).abs();
    final dy = (shoulderMidY - nose.y).abs();
    forwardHeadAngle = dy > 0 ? (atan2(dx, dy) * 180 / pi) : 0;
  }
  final b1Status = forwardHeadAngle < 5 ? 'good' : forwardHeadAngle < 10 ? 'mild' : 'moderate';
  measurements.add(PostureMeasurement(
    code: 'B1', label: 'Forward Head / Body Alignment (Side)',
    angleDeg: forwardHeadAngle,
    status: b1Status,
    finding: b1Status == 'good'
        ? 'No forward head posture detected'
        : 'Forward head posture ${forwardHeadAngle.toStringAsFixed(1)}° increases neck load',
  ));
  if (b1Status != 'good') {
    problems.add('Forward head posture');
    exercises.add(const ExerciseSuggestion(
      name: 'Chin Tucks',
      description: 'Gently pull chin backward making a "double chin". Hold 5 seconds.',
      sets: '3', reps: '12 to 15',
      tip: 'Do this against a wall for feedback. Keep eyes level.',
      icon: Icons.face,
    ));
    exercises.add(const ExerciseSuggestion(
      name: 'Hands Behind Head',
      description: 'Place hands behind head, open elbows wide, gently press head back.',
      sets: '3', reps: '10',
      tip: 'Do not pull neck with hands use as gentle resistance only.',
      icon: Icons.sports,
    ));
  }

  // ── Overall Score ─────────────────────────────────────────────────────────
  final severeCount   = measurements.where((m) => m.status == 'severe').length;
  final moderateCount = measurements.where((m) => m.status == 'moderate').length;
  final mildCount     = measurements.where((m) => m.status == 'mild').length;

  String overallStatus;
  String summary;
  if (severeCount > 0) {
    overallStatus = 'severe';
    summary = 'Significant postural misalignments detected. Please consult a physiotherapist or specialist for a detailed assessment and treatment plan.';
  } else if (moderateCount >= 2) {
    overallStatus = 'moderate';
    summary = 'Multiple postural imbalances detected. With high probability we have detected body misalignments. Please take deeper posture assessments and further consultations with your specialist.';
  } else if (moderateCount == 1 || mildCount >= 2) {
    overallStatus = 'mild';
    summary = 'Mild postural deviations detected. Begin the suggested corrective exercises daily. Re assess in 4 to 6 weeks.';
  } else {
    overallStatus = 'good';
    summary = 'Excellent posture! Your body alignment looks great. Continue maintaining good posture habits and staying active.';
  }

  // ── Always add general exercise if no specific exercises found ────────────
  if (exercises.isEmpty) {
    exercises.add(const ExerciseSuggestion(
      name: 'Mountain Pose Hold',
      description: 'Stand tall, feet hip width, arms at sides. Breathe deeply.',
      sets: '3', reps: '60 sec',
      tip: 'Imagine a string pulling your head toward the ceiling.',
      icon: Icons.self_improvement,
    ));
  }

  // Deduplicate exercises
  final seen = <String>{};
  final uniqueExercises = exercises.where((e) => seen.add(e.name)).toList();

  return PostureReport(
    measurements: measurements,
    problems: problems,
    exercises: uniqueExercises,
    overallStatus: overallStatus,
    summary: summary,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ROOT APP
// ═══════════════════════════════════════════════════════════════════════════════
class APECSApp extends StatelessWidget {
  const APECSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Posture Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _blue),
        scaffoldBackgroundColor: _bg,
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          color: _card,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  File?          _image;
  Size           _imageSize = Size.zero;
  List<Pose>     _poses     = [];
  PostureReport? _report;
  bool           _isLoading = false;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single),
  );

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _detector.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source, maxWidth: 1920, maxHeight: 1920, imageQuality: 92,
    );
    if (file == null) return;

    setState(() { _isLoading = true; _report = null; _poses = []; });
    _fadeCtrl.reset();

    try {
      final imageFile  = File(file.path);
      final bytes      = await imageFile.readAsBytes();
      final decoded    = await decodeImageFromList(bytes);

      setState(() {
        _image     = imageFile;
        _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
      });

      final input = InputImage.fromFile(imageFile);
      final poses = await _detector.processImage(input);
      final report = analyzePosture(poses);

      setState(() { _poses = poses; _report = report; _isLoading = false; });
      _fadeCtrl.forward();
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _report == null ? _buildUploadView() : _buildReportView(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [

          /// 🔙 BACK BUTTON
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _blue),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          /// LOGO
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              'https://i.imgur.com/placeholder.png',
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.accessibility, color: _blue, size: 28),
            ),
          ),

          const SizedBox(width: 10),

          /// TITLE
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ZEROMEDIXINE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _blue,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'AI Posture Evaluation & Correction System',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const Spacer(),

          /// NEW BUTTON
          if (_report != null)
            TextButton.icon(
              onPressed: () => setState(() {
                _report = null;
                _image = null;
                _poses = [];
              }),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('New', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ── Upload View ───────────────────────────────────────────────────────────
  Widget _buildUploadView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hero upload card
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _blue.withOpacity(0.3), width: 2),
              boxShadow: [BoxShadow(color: _blue.withOpacity(0.08), blurRadius: 20)],
            ),
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: _blue),
                  const SizedBox(height: 16),
                  Text('Analyzing posture…',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            )
                : _image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(_image!, fit: BoxFit.cover),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_search, size: 64, color: _blue.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text('Upload a Full Body Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: _blue)),
                const SizedBox(height: 8),
                Text('Stand facing camera for best results',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickChip(label: '📸 Front View'),
                    const SizedBox(width: 8),
                    _QuickChip(label: '🧍 Full Body'),
                    const SizedBox(width: 8),
                    _QuickChip(label: '💡 Good Lighting'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info cards
          Row(
            children: [
              Expanded(child: _InfoTile(icon: Icons.straighten, title: '7 Measurements',
                  sub: 'Body, Head, Shoulder, Pelvis, Knees, Feet', color: _blue)),
              const SizedBox(width: 12),
              Expanded(child: _InfoTile(icon: Icons.fitness_center, title: 'Exercise Plan',
                  sub: 'Customised corrective exercises', color: _orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _InfoTile(icon: Icons.warning_amber, title: 'Problem Detection',
                  sub: 'Head tilt, shoulder imbalance, pelvic shift', color: _red)),
              const SizedBox(width: 12),
              Expanded(child: _InfoTile(icon: Icons.description, title: 'Full Report',
                  sub: 'GOOGLE-style posture report card', color: _green)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Full Report View ──────────────────────────────────────────────────────
  Widget _buildReportView() {
    final report = _report!;
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date line
            Text(
              'Date: ${DateTime.now().day.toString().padLeft(2,'0')}/'
                  '${DateTime.now().month.toString().padLeft(2,'0')}/'
                  '${DateTime.now().year}   |   AI Quick Analysis',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // ── Image with skeleton ──────────────────────────────────────
            if (_image != null)
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 260,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_image!, fit: BoxFit.contain),
                        if (_poses.isNotEmpty)
                          LayoutBuilder(builder: (ctx, c) => CustomPaint(
                            painter: PosePainter(
                              poses: _poses, imageSize: _imageSize,
                              displaySize: Size(c.maxWidth, c.maxHeight),
                            ),
                          )),
                        // Status badge
                        Positioned(
                          top: 10, left: 10,
                          child: _StatusBadge(status: report.overallStatus),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_image == null || _report == null) return;

                  final file = await PosturePdfService.generateReport(
                    image: _image!,
                    report: _report!,
                  );

                  await PosturePdfService.sharePdf(file);
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  "Export & Share PDF",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Overall finding ──────────────────────────────────────────
            _SectionHeader(title: 'Complete Posture Overview', color: _headerBg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_statusIcon(report.overallStatus),
                            color: _statusColor(report.overallStatus), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(report.summary,
                              style: const TextStyle(fontSize: 13, height: 1.5)),
                        ),
                      ],
                    ),
                    if (report.problems.isNotEmpty) ...[
                      const Divider(height: 20),
                      const Text('Issues Found:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      ...report.problems.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 14, color: _red),
                            const SizedBox(width: 6),
                            Expanded(child: Text(p, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── A. FRONT measurements ────────────────────────────────────
            _SectionHeader(title: 'A. FRONT VIEW Measurements', color: _headerBg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _MeasurementTableHeader(),
                    ...report.measurements
                        .where((m) => m.code.startsWith('A'))
                        .map((m) => _MeasurementRow(m: m)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── B. SIDE measurement ──────────────────────────────────────
            _SectionHeader(title: 'B. RIGHT SIDE Measurements', color: _headerBg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _MeasurementTableHeader(),
                    ...report.measurements
                        .where((m) => m.code.startsWith('B'))
                        .map((m) => _MeasurementRow(m: m)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Detailed Findings ────────────────────────────────────────
            _SectionHeader(title: 'Detailed Findings', color: const Color(0xFFFFF3E0)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: report.measurements.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: _statusColor(m.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(m.code,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold,
                                    color: _statusColor(m.status))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(m.finding,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                        _AngleBadge(angle: m.angleDeg, status: m.status),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Selected Exercises ───────────────────────────────────────
            _SectionHeader(title: 'Selected Exercises', color: const Color(0xFFE8F5E9)),
            Text(
              'Refer to the exercise descriptions below. Perform daily for best results.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            ...report.exercises.asMap().entries.map((e) =>
                _ExerciseCard(number: e.key + 1, exercise: e.value)),

            const SizedBox(height: 20),
            // Footer
            Center(
              child: Text(
                'AI Posture Analysis  •  ${DateTime.now().year}  •  Powered by ML Kit',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

    );

  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12, left: 40, right: 40,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BarBtn(icon: Icons.photo_library_outlined, label: 'Gallery',
              onTap: _isLoading ? null : () => _pickImage(ImageSource.gallery)),
          GestureDetector(
            onTap: _isLoading ? null : () => _pickImage(ImageSource.gallery),
            child: Container(
              width: 62, height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _blue,
                boxShadow: [BoxShadow(color: _blue.withOpacity(0.4),
                    blurRadius: 16, spreadRadius: 2)],
              ),
              child: const Icon(Icons.person_search, color: Colors.white, size: 28),
            ),
          ),
          _BarBtn(icon: Icons.camera_alt_outlined, label: 'Camera',
              onTap: _isLoading ? null : () => _pickImage(ImageSource.camera)),
        ],
      ),
    );
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'good':     return Icons.check_circle_outline;
      case 'mild':     return Icons.info_outline;
      case 'moderate': return Icons.warning_amber;
      case 'severe':   return Icons.error_outline;
      default:         return Icons.help_outline;
    }
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'good':     return _green;
    case 'mild':     return _amber;
    case 'moderate': return _orange;
    case 'severe':   return _red;
    default:         return Colors.grey;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'good':     return 'Good';
    case 'mild':     return 'Mild';
    case 'moderate': return 'Moderate';
    case 'severe':   return 'Severe';
    default:         return 'Unknown';
  }
}


// ═══════════════════════════════════════════════════════════════════════════════
//  SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _QuickChip extends StatelessWidget {
  final String label;
  const _QuickChip({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: _blue.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _blue.withOpacity(0.2)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 11, color: _blue)),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  const _InfoTile({required this.icon, required this.title, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
  );
}

class _MeasurementTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: const Row(
      children: [
        SizedBox(width: 36, child: Text('Label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        Expanded(child: Text('Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        SizedBox(width: 60, child: Text('Value', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
        SizedBox(width: 72, child: Text('Status', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
      ],
    ),
  );
}

class _MeasurementRow extends StatelessWidget {
  final PostureMeasurement m;
  const _MeasurementRow({required this.m});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
    ),
    child: Row(
      children: [
        SizedBox(width: 36,
            child: Text(m.code,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                    color: _statusColor(m.status)))),
        Expanded(child: Text(m.label, style: const TextStyle(fontSize: 12))),
        SizedBox(width: 60,
            child: Text('${m.angleDeg.toStringAsFixed(0)}°',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        SizedBox(
          width: 72,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor(m.status).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_statusLabel(m.status),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: _statusColor(m.status))),
          ),
        ),
      ],
    ),
  );
}

class _AngleBadge extends StatelessWidget {
  final double angle;
  final String status;
  const _AngleBadge({required this.angle, required this.status});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _statusColor(status).withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('${angle.toStringAsFixed(1)}°',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
            color: _statusColor(status))),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final icons = {
      'good': Icons.check_circle, 'mild': Icons.info,
      'moderate': Icons.warning, 'severe': Icons.error,
    };
    final labels = {
      'good': 'Good Posture', 'mild': 'Mild Issues',
      'moderate': 'Needs Attention', 'severe': 'See Specialist',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _statusColor(status).withOpacity(0.4), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[status] ?? Icons.info, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(labels[status] ?? 'Unknown',
              style: const TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int number;
  final ExerciseSuggestion exercise;
  const _ExerciseCard({required this.number, required this.exercise});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('$number',
                  style: const TextStyle(fontWeight: FontWeight.bold,
                      color: _blue, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(exercise.icon, color: _blue, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 5),
                Text(exercise.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ExChip(label: '${exercise.sets} Sets', color: _blue),
                    const SizedBox(width: 6),
                    _ExChip(label: exercise.reps, color: _orange),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, size: 12, color: _amber),
                      const SizedBox(width: 5),
                      Expanded(child: Text('Tip: ${exercise.tip}',
                          style: const TextStyle(fontSize: 11, color: Colors.black87))),
                    ],
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

class _ExChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ExChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
  );
}

class _BarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _BarBtn({required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: onTap == null ? Colors.grey.shade300 : Colors.grey.shade700, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    ),
  );
}
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size displaySize;

  const PosePainter({required this.poses, required this.imageSize, required this.displaySize});

  static const _connections = [
    [PoseLandmarkType.leftEar,       PoseLandmarkType.leftEye],
    [PoseLandmarkType.leftEye,       PoseLandmarkType.nose],
    [PoseLandmarkType.nose,          PoseLandmarkType.rightEye],
    [PoseLandmarkType.rightEye,      PoseLandmarkType.rightEar],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow,     PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow,    PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftHip,       PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee,      PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip,      PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee,     PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.leftShoulder,  PoseLandmarkType.nose],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.nose],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = displaySize.width  / imageSize.width;
    final scaleY = displaySize.height / imageSize.height;
    final scale  = min(scaleX, scaleY);
    final offX   = (displaySize.width  - imageSize.width  * scale) / 2;
    final offY   = (displaySize.height - imageSize.height * scale) / 2;

    Offset toScreen(PoseLandmark lm) =>
        Offset(lm.x * scale + offX, lm.y * scale + offY);

    // Line colors by body part
    final torsoP = Paint()..color = const Color(0xFF1565C0).withOpacity(0.9)
      ..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final limbP  = Paint()..color = const Color(0xFFF57C00).withOpacity(0.9)
      ..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

    final dotP   = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final ringP  = Paint()..color = const Color(0xFF1565C0)..style = PaintingStyle.fill;
    final glowP  = Paint()..color = const Color(0xFF1565C0).withOpacity(0.2)..style = PaintingStyle.fill;

    // Measurement lines (horizontal alignment lines)
    final alignP = Paint()..color = Colors.yellow.withOpacity(0.7)
      ..strokeWidth = 1.5..style = PaintingStyle.stroke;

    for (final pose in poses) {
      final lms = pose.landmarks;

      // Draw connections
      for (final conn in _connections) {
        final a = lms[conn[0]]; final b = lms[conn[1]];
        if (a != null && b != null && a.likelihood > 0.4 && b.likelihood > 0.4) {
          final isTorso = conn.contains(PoseLandmarkType.leftShoulder) &&
              conn.contains(PoseLandmarkType.rightShoulder) ||
              conn.contains(PoseLandmarkType.leftHip) &&
                  conn.contains(PoseLandmarkType.rightHip) ||
              conn.contains(PoseLandmarkType.leftShoulder) &&
                  conn.contains(PoseLandmarkType.leftHip) ||
              conn.contains(PoseLandmarkType.rightShoulder) &&
                  conn.contains(PoseLandmarkType.rightHip);
          canvas.drawLine(toScreen(a), toScreen(b), isTorso ? torsoP : limbP);
        }
      }

      // Horizontal alignment lines (like APECS yellow lines)
      final ls = lms[PoseLandmarkType.leftShoulder];
      final rs = lms[PoseLandmarkType.rightShoulder];
      final lh = lms[PoseLandmarkType.leftHip];
      final rh = lms[PoseLandmarkType.rightHip];
      final lk = lms[PoseLandmarkType.leftKnee];
      final rk = lms[PoseLandmarkType.rightKnee];

      if (ls != null && rs != null) {
        final pts = toScreen(ls); final ptr = toScreen(rs);
        canvas.drawLine(
            Offset(pts.dx - 20, pts.dy), Offset(ptr.dx + 20, ptr.dy), alignP);
      }
      if (lh != null && rh != null) {
        final ptl = toScreen(lh); final ptr = toScreen(rh);
        canvas.drawLine(
            Offset(ptl.dx - 20, ptl.dy), Offset(ptr.dx + 20, ptr.dy), alignP);
      }
      if (lk != null && rk != null) {
        final ptl = toScreen(lk); final ptr = toScreen(rk);
        canvas.drawLine(
            Offset(ptl.dx - 10, ptl.dy), Offset(ptr.dx + 10, ptr.dy), alignP);
      }

      // Vertical center line
      if (ls != null && rs != null && lh != null && rh != null) {
        final topX = (toScreen(ls).dx + toScreen(rs).dx) / 2;
        final botX = (toScreen(lh).dx + toScreen(rh).dx) / 2;
        final topY = toScreen(ls).dy;
        final botY = toScreen(lh).dy + 60;
        final vLinePaint = Paint()
          ..color = Colors.red.withOpacity(0.7)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(topX, topY - 40), Offset(botX, botY), vLinePaint);
      }

      // Draw keypoints
      for (final lm in lms.values) {
        if (lm.likelihood > 0.4) {
          final pt = toScreen(lm);
          canvas.drawCircle(pt, 10, glowP);
          canvas.drawCircle(pt, 5,  ringP);
          canvas.drawCircle(pt, 2.5, dotP);
        }
      }
    }
  }



  @override
  bool shouldRepaint(PosePainter old) =>
      old.poses != poses || old.imageSize != imageSize;
}
