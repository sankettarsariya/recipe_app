import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/notification_service.dart';
import '../../home/views/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeTop;
  late final Animation<double> _fadeBottom;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeTop = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _fadeBottom = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );

    _slideUp =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)),
    );

    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    await NotificationService.instance.scheduleAllMealNotifications();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1917),
      body: Stack(
        children: [
          // ── Decorative corner lines ──────────────────────
          Positioned(
            top: 0,
            left: 0,
            child: FadeTransition(
              opacity: _fadeTop,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _CornerLinePainter(topLeft: true),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeTop,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _CornerLinePainter(topLeft: false),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo block
                FadeTransition(
                  opacity: _fadeTop,
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFB5651D), width: 1.5),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 32,
                          color: Color(0xFFB5651D),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'SAVEUR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Divider line
                FadeTransition(
                  opacity: _fadeTop,
                  child: Container(
                    width: 40,
                    height: 1.5,
                    color: const Color(0xFFB5651D),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _fadeBottom,
                    child: const Text(
                      'Smart meals for every moment',
                      style: TextStyle(
                        color: Color(0xFF9A8F82),
                        fontSize: 13,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom credit ─────────────────────────────────
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeBottom,
              child: const Column(
                children: [
                  _LoadingDots(),
                  SizedBox(height: 20),
                  Text(
                    'CRAFTED WITH CARE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF44403C),
                      fontSize: 9,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated loading dots ───────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Color.fromRGBO(181, 101, 29, opacity.clamp(0.2, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Corner decorative line painter ─────────────────────────────
class _CornerLinePainter extends CustomPainter {
  final bool topLeft;
  const _CornerLinePainter({required this.topLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB5651D).withOpacity(0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    if (topLeft) {
      canvas.drawLine(const Offset(40, 0), const Offset(40, 40), paint);
      canvas.drawLine(const Offset(40, 40), const Offset(0, 40), paint);
      canvas.drawLine(const Offset(70, 0), const Offset(70, 20), paint);
      canvas.drawLine(const Offset(0, 70), const Offset(20, 70), paint);
    } else {
      final w = size.width;
      final h = size.height;
      canvas.drawLine(Offset(w - 40, h), Offset(w - 40, h - 40), paint);
      canvas.drawLine(Offset(w - 40, h - 40), Offset(w, h - 40), paint);
      canvas.drawLine(Offset(w - 70, h), Offset(w - 70, h - 20), paint);
      canvas.drawLine(Offset(w, h - 70), Offset(w - 20, h - 70), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
