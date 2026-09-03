import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  // ==========================================================
  // IMAGE
  // ==========================================================

  XFile? selectedImage;

  final ImagePicker _picker = ImagePicker();

  // ==========================================================
  // AI STATE
  // ==========================================================

  bool isAnalyzing = false;
  bool hasResult = false;

  // Temporary demo result.
  // Later these values will come from your AI model/API.
  String diseaseName = 'Healthy Paddy';
  double confidence = 0.94;

  // ==========================================================
  // TAKE PHOTO
  // ==========================================================

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage = image;
        hasResult = false;
      });
    } catch (e) {
      _showError('Unable to open camera.\n$e');
    }
  }

  // ==========================================================
  // UPLOAD FROM GALLERY
  // ==========================================================

  Future<void> uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        selectedImage = image;
        hasResult = false;
      });
    } catch (e) {
      _showError('Unable to select image.\n$e');
    }
  }

  // ==========================================================
  // ANALYZE IMAGE
  // ==========================================================

  Future<void> analyzeImage() async {
    if (selectedImage == null) {
      _showError('Please select or capture a crop image first.');
      return;
    }

    setState(() {
      isAnalyzing = true;
      hasResult = false;
    });

    // ========================================================
    // TEMPORARY DEMO
    //
    // Later replace this section with:
    //
    // Flutter
    //    ↓
    // POST /disease/predict
    //    ↓
    // FastAPI
    //    ↓
    // InceptionV3 / your trained model
    //    ↓
    // prediction
    // ========================================================

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      isAnalyzing = false;
      hasResult = true;

      diseaseName = 'Healthy Paddy';
      confidence = 0.94;
    });
  }

  // ==========================================================
  // RESET
  // ==========================================================

  void chooseAnotherImage() {
    setState(() {
      selectedImage = null;
      hasResult = false;
      isAnalyzing = false;
    });
  }

  // ==========================================================
  // ERROR MESSAGE
  // ==========================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F3),
        elevation: 0,

        title: const Text(
          'AI Crop Doctor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // INTRO
            // ==================================================

            _buildIntroCard(),

            const SizedBox(height: 22),

            const Text(
              'Crop Disease Detection',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // IMAGE
            // ==================================================
            _buildImageSection(),

            // ==================================================
            // ANALYZE
            // ==================================================
            if (selectedImage != null) ...[
              const SizedBox(height: 16),

              _buildAnalyzeButton(),
            ],

            // ==================================================
            // ANALYZING
            // ==================================================
            if (isAnalyzing) ...[
              const SizedBox(height: 18),

              _buildAnalyzingCard(),
            ],

            // ==================================================
            // RESULT
            // ==================================================
            if (hasResult) ...[
              const SizedBox(height: 24),

              const Text(
                'Detection Result',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              _buildResultCard(),

              const SizedBox(height: 14),

              _buildRecommendationCard(),

              const SizedBox(height: 16),

              _buildAnotherImageButton(),
            ],

            // ==================================================
            // TIPS
            // ==================================================
            if (selectedImage == null) ...[
              const SizedBox(height: 24),

              _buildImageTips(),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INTRO CARD
  // ==========================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Colors.green.shade50, Colors.white],
        ),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: Colors.green.shade100),
      ),

      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade100,
            ),

            child: Icon(
              Icons.eco_rounded,
              size: 30,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Check your crop health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Text(
                  'Take or upload a clear leaf photo '
                  'to detect possible crop diseases.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // IMAGE SECTION
  // ==========================================================

  Widget _buildImageSection() {
    // --------------------------------------------------------
    // NO IMAGE
    // --------------------------------------------------------

    if (selectedImage == null) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          children: [
            Container(
              width: 78,
              height: 78,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
              ),

              child: Icon(
                Icons.add_a_photo_rounded,
                size: 38,
                color: Colors.green.shade700,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Add a photo of the crop leaf',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              'Use a clear, well-lit image',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                // CAMERA
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: takePhoto,

                    icon: const Icon(Icons.camera_alt_rounded),

                    label: const Text('Take Photo'),

                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      side: BorderSide(color: Colors.green.shade300),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // GALLERY
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: uploadImage,

                    icon: const Icon(Icons.photo_library_rounded),

                    label: const Text('Upload'),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(vertical: 14),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // --------------------------------------------------------
    // IMAGE SELECTED
    // --------------------------------------------------------

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(17),

            child: Image.file(
              File(selectedImage!.path),

              width: double.infinity,

              height: 250,

              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: Colors.green,
              ),

              const SizedBox(width: 7),

              const Expanded(
                child: Text(
                  'Image ready for analysis',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              TextButton(
                onPressed: chooseAnotherImage,

                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ANALYZE BUTTON
  // ==========================================================

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton.icon(
        onPressed: isAnalyzing ? null : analyzeImage,

        icon: Icon(
          isAnalyzing
              ? Icons.hourglass_top_rounded
              : Icons.auto_awesome_rounded,
        ),

        label: Text(isAnalyzing ? 'Analyzing...' : 'Analyze Crop'),

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,

          foregroundColor: Colors.white,

          disabledBackgroundColor: Colors.grey.shade300,

          disabledForegroundColor: Colors.grey.shade600,

          padding: const EdgeInsets.symmetric(vertical: 16),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ANALYZING
  // ==========================================================

  Widget _buildAnalyzingCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        children: [
          const SizedBox(
            width: 35,
            height: 35,

            child: CircularProgressIndicator(strokeWidth: 3),
          ),

          const SizedBox(height: 14),

          const Text(
            'Analyzing your crop...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            'AI is checking the leaf image',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RESULT
  // ==========================================================

  Widget _buildResultCard() {
    final int confidencePercent = (confidence * 100).round();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.green.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),

                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.green.shade700,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Detected condition',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      diseaseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge('Healthy', Colors.green),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'AI Confidence',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              Text(
                '$confidencePercent%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: confidence,

              minHeight: 8,

              backgroundColor: Colors.grey.shade200,

              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RECOMMENDATION
  // ==========================================================

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.shade50,
                ),

                child: Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.orange.shade700,
                  size: 22,
                ),
              ),

              const SizedBox(width: 11),

              const Text(
                'Recommendation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            'Your crop appears healthy. Continue '
            'regular monitoring and maintain proper '
            'irrigation and field conditions.',

            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Note: AI results are advisory. '
            'Confirm serious disease symptoms with '
            'an agricultural expert.',

            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ANOTHER IMAGE
  // ==========================================================

  Widget _buildAnotherImageButton() {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton.icon(
        onPressed: chooseAnotherImage,

        icon: const Icon(Icons.add_a_photo_rounded),

        label: const Text('Analyze Another Image'),

        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE TIPS
  // ==========================================================

  Widget _buildImageTips() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'For better detection',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _tipRow(Icons.wb_sunny_rounded, 'Use good natural lighting'),

          _tipRow(
            Icons.center_focus_strong_rounded,
            'Keep the leaf clearly visible',
          ),

          _tipRow(Icons.image_rounded, 'Avoid blurry or dark photos'),

          _tipRow(Icons.crop_free_rounded, 'Capture the affected area closely'),
        ],
      ),
    );
  }

  Widget _tipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),

      child: Row(
        children: [
          Icon(icon, size: 19, color: Colors.green.shade700),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              text,

              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATUS BADGE
  // ==========================================================

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        text,

        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}
