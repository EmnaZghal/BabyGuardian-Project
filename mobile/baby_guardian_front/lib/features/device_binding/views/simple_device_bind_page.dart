import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:baby_guardian_front/features/auth/service/auth_service.dart';
import 'package:baby_guardian_front/features/babies_page_selection/services/baby_api.dart';

class SimpleDeviceBindPage extends StatefulWidget {
  final String babyId;
  final String? babyName;

  const SimpleDeviceBindPage({
    super.key,
    required this.babyId,
    this.babyName,
  });

  @override
  State<SimpleDeviceBindPage> createState() => _SimpleDeviceBindPageState();
}

class _SimpleDeviceBindPageState extends State<SimpleDeviceBindPage> {
  final _auth = AuthService();
  
  // ✅ DEVICE ID STATIQUE
  static const String _staticDeviceId = 'esp32-c00aa81f8a3c';
  
  bool _binding = false;

  void _safeBack() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/select-baby');
    }
  }

  Future<void> _bindDevice() async {
    setState(() => _binding = true);

    try {
      print('🔗 [Bind] Starting device binding...');
      print('👶 [Bind] Baby ID: ${widget.babyId}');
      print('📟 [Bind] Device ID: $_staticDeviceId');

      await BabyApi.bindDevice(
        auth: _auth,
        babyId: widget.babyId,
        deviceId: _staticDeviceId,
      );

      if (!mounted) return;

      print('✅ [Bind] Device linked successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Device linked successfully!\nesp32-c00aa81f8a3c'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        print('🏠 [Bind] Navigating to /home');
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      
      print('❌ [Bind] Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error binding device: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _binding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final babyLabel = widget.babyName?.isNotEmpty == true
        ? widget.babyName!
        : 'Selected Baby';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: _safeBack,
        ),
        title: const Text(
          'Link Device to Baby',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baby info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.child_care,
                          color: Color(0xFF16A34A),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Baby',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              babyLabel,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Device info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.router,
                              color: Color(0xFF16A34A),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ESP32 Device',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text(
                        'Device ID',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fingerprint,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _staticDeviceId,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Info message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This will link your ESP32 device to $babyLabel. '
                          'Make sure the device is powered on and connected to WiFi.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1E40AF),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bind button
                ElevatedButton(
                  onPressed: _binding ? null : _bindDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                  ),
                  child: _binding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.link, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Link Device to Baby',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: _binding ? null : () => context.go('/home'),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}