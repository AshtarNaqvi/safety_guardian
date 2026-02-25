import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/custom_button.dart';

class EvidenceCaptureScreen extends StatefulWidget {
  const EvidenceCaptureScreen({super.key});

  @override
  State<EvidenceCaptureScreen> createState() => _EvidenceCaptureScreenState();
}

class _EvidenceCaptureScreenState extends State<EvidenceCaptureScreen> with SingleTickerProviderStateMixin {
  // Animation for recording
  late AnimationController _pulseAnimation;
  late Animation<double> _pulseScale;
  
  // State variables
  bool _isPanicMode = false;
  bool _isAudioRecording = false;
  bool _isVideoRecording = false;
  bool _isLocationLogging = false;
  bool _isFrontCamera = false;
  String _recordingStatus = 'Standby';
  Color _statusColor = Colors.grey;
  
  // Timer for recording duration
  int _recordingSeconds = 0;
  
  // Evidence files list
  List<Map<String, dynamic>> _evidenceFiles = [
    {'type': 'audio', 'name': 'audio_001.m4a', 'time': '2 min ago', 'size': '2.4 MB', 'duration': '0:45'},
    {'type': 'video', 'name': 'video_001.mp4', 'time': '5 min ago', 'size': '15.2 MB', 'duration': '1:30'},
    {'type': 'location', 'name': 'location_001.log', 'time': '10 min ago', 'size': '0.8 MB', 'points': '127'},
    {'type': 'video', 'name': 'video_002.mp4', 'time': '15 min ago', 'size': '8.7 MB', 'duration': '0:52'},
    {'type': 'audio', 'name': 'audio_002.m4a', 'time': '20 min ago', 'size': '1.8 MB', 'duration': '0:32'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Setup pulse animation for recording
    _pulseAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseAnimation, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseAnimation.dispose();
    super.dispose();
  }

  // Activate panic mode
  void _activatePanicMode() {
    setState(() {
      _isPanicMode = true;
      _isAudioRecording = true;
      _isVideoRecording = true;
      _isLocationLogging = true;
      _recordingStatus = 'PANIC MODE ACTIVE';
      _statusColor = Colors.red;
      _recordingSeconds = 0;
    });
    
    // Start recording timer
    _startRecordingTimer();
    
    // Show confirmation
    _showPanicModeDialog();
  }

  // Deactivate panic mode
  void _deactivatePanicMode() {
    setState(() {
      _isPanicMode = false;
      _isAudioRecording = false;
      _isVideoRecording = false;
      _isLocationLogging = false;
      _recordingStatus = 'Standby';
      _statusColor = Colors.grey;
    });
    
    // Add to evidence list
    _addEvidenceFile('audio', 'audio_recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
    _addEvidenceFile('video', 'video_recording_${DateTime.now().millisecondsSinceEpoch}.mp4');
    _addEvidenceFile('location', 'location_log_${DateTime.now().millisecondsSinceEpoch}.log');
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evidence saved securely'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Start recording timer
  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isPanicMode) {
        setState(() {
          _recordingSeconds++;
        });
        _startRecordingTimer();
      }
    });
  }

  // Format recording time
  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Add evidence file to list
  void _addEvidenceFile(String type, String name) {
    setState(() {
      _evidenceFiles.insert(0, {
        'type': type,
        'name': name,
        'time': 'Just now',
        'size': type == 'audio' ? '1.2 MB' : type == 'video' ? '5.4 MB' : '0.3 MB',
        'duration': type == 'audio' ? '0:30' : type == 'video' ? '0:45' : null,
        'points': type == 'location' ? '42' : null,
      });
    });
  }

  // Show panic mode dialog
  void _showPanicModeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Icon(
          Icons.warning,
          color: Colors.red,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PANIC MODE ACTIVATED',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Recording audio, video, and location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'Evidence is being captured and securely stored even if phone is locked',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Toggle front/back camera
  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFrontCamera ? 'Front camera active' : 'Back camera active'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Capture'),
        backgroundColor: _isPanicMode ? Colors.red : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.info_circle),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _isPanicMode ? Colors.red.withOpacity(0.1) : const Color(0xFF2563EB).withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Status Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: _isPanicMode ? Colors.red.shade50 : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _isPanicMode ? _pulseScale.value : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _isPanicMode
                                          ? Colors.red.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isPanicMode
                                          ? Iconsax.video
                                          : Iconsax.security,
                                      color: _isPanicMode ? Colors.red : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Evidence Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    _recordingStatus,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isPanicMode) ...[
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.circle, color: Colors.red, size: 12),
                                const SizedBox(width: 8),
                                Text(
                                  'Recording: ${_formatTime(_recordingSeconds)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Panic Button
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: !_isPanicMode ? _pulseScale.value : 1.0,
                        child: GestureDetector(
                          onTap: _isPanicMode ? _deactivatePanicMode : _activatePanicMode,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: _isPanicMode
                                    ? [Colors.green, Colors.green.shade700]
                                    : [Colors.red, Colors.red.shade700],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isPanicMode
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.red.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isPanicMode ? Icons.stop : Icons.warning,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _isPanicMode ? 'STOP' : 'PANIC',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_isPanicMode)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                      'Tap to stop recording',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Recording Controls Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Recording',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        // Audio recording
                        _buildRecordingRow(
                          icon: Iconsax.microphone,
                          title: 'Background Audio',
                          isActive: _isAudioRecording,
                          color: Colors.blue,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Video recording
                        _buildRecordingRow(
                          icon: Iconsax.video,
                          title: 'Video Recording',
                          isActive: _isVideoRecording,
                          color: Colors.red,
                          trailing: _isVideoRecording
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isFrontCamera ? Iconsax.camera : Iconsax.camera,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      onPressed: _toggleCamera,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _isFrontCamera ? 'Front' : 'Back',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Location logging
                        _buildRecordingRow(
                          icon: Iconsax.location,
                          title: 'Location Logging',
                          isActive: _isLocationLogging,
                          color: Colors.green,
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Info about secure storage
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.lock,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Secure Storage Active',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    Text(
                                      'Evidence saved even if phone is locked',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Evidence Files Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Saved Evidence',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Evidence list
                        ..._evidenceFiles.take(4).map((file) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: file['type'] == 'audio'
                                        ? Colors.blue.shade100
                                        : file['type'] == 'video'
                                            ? Colors.red.shade100
                                            : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    file['type'] == 'audio'
                                        ? Iconsax.microphone
                                        : file['type'] == 'video'
                                            ? Iconsax.video
                                            : Iconsax.location,
                                    color: file['type'] == 'audio'
                                        ? Colors.blue
                                        : file['type'] == 'video'
                                            ? Colors.red
                                            : Colors.green,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file['name'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            file['time'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          Text(
                                            ' • ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          Text(
                                            file['size'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          if (file['duration'] != null) ...[
                                            Text(
                                              ' • ',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Text(
                                              file['duration'],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                          if (file['points'] != null) ...[
                                            Text(
                                              ' • ',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Text(
                                              '${file['points']} points',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, size: 16),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Features Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: Iconsax.microphone,
                          title: 'Background Audio Recording',
                          subtitle: 'Records audio even when screen is off',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          icon: Iconsax.video,
                          title: 'Dual Camera Recording',
                          subtitle: 'Front and back cameras simultaneously',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          icon: Iconsax.location,
                          title: 'Continuous Location Logging',
                          subtitle: 'Tracks location every 5 seconds',
                        ),
                        const Divider(),
                        _buildFeatureRow(
                          icon: Iconsax.lock,
                          title: 'Secure Storage',
                          subtitle: 'Evidence saved if phone is locked',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Storage Info
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Iconsax.document, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Storage Usage',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: 0.35,
                              backgroundColor: Colors.blue.shade100,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '35% used • 12.5 GB free',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingRow({
    required IconData icon,
    required String title,
    required bool isActive,
    required Color color,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? color.withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? color : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (trailing == null)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.grey.shade300,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Evidence Capture',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(
              icon: Iconsax.microphone,
              title: 'Background Audio',
              description: 'Records audio even when phone is locked',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Iconsax.video,
              title: 'Video Recording',
              description: 'Front and back cameras record simultaneously',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Iconsax.location,
              title: 'Location Logging',
              description: 'Continuous location tracking',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Iconsax.lock,
              title: 'Secure Storage',
              description: 'Evidence saved even if phone is locked or in pocket',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}