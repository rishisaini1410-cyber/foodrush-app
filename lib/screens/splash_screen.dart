import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'auth/auth_screen.dart';
import '../services/auth_service.dart';
import 'main/main_tabs_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _title = 'Food Rush';
  static const _tagline = 'Indian cravings, delivered with style.';

  late final AnimationController _assembleController;
  late final AnimationController _taglineController;
  late final AnimationController _loaderController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final List<_LetterFlight> _letters;

  @override
  void initState() {
    super.initState();

    _assembleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _letters = _buildLetterFlights();

    _assembleController.forward().then((_) {
      if (!mounted) return;
      _taglineController.forward();
      _pulseController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 4200), () async {
      if (!mounted) return;
      final session = await AuthService().getSessionUser();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => session != null ? const MainTabsScreen() : const AuthScreen(),
        ),
      );
    });
  }

  List<_LetterFlight> _buildLetterFlights() {
    const origins = [
      Offset(-0.95, -0.85),
      Offset(0.95, -0.75),
      Offset(-0.9, 0.85),
      Offset(0.9, 0.8),
      Offset(-0.55, -0.95),
      Offset(0.55, -0.95),
      Offset(-0.95, 0.15),
      Offset(0.95, 0.15),
      Offset(0.0, -0.95),
    ];

    return List.generate(_title.length, (index) {
      final char = _title[index];
      if (char == ' ') {
        return _LetterFlight(
          char: char,
          origin: Offset.zero,
          delay: 0,
          isSpace: true,
        );
      }

      return _LetterFlight(
        char: char,
        origin: origins[index % origins.length],
        delay: index * 0.07,
      );
    });
  }

  @override
  void dispose() {
    _assembleController.dispose();
    _taglineController.dispose();
    _loaderController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF144E2C), Color(0xFFF16F24)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _FloatingIconsPainter(t: _floatController.value),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _assembleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GlowPainter(progress: _assembleController.value),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([_assembleController, _pulseController]),
                    builder: (context, _) {
                      final pulse = _assembleController.isCompleted
                          ? 1.0 + (_pulseController.value * 0.04)
                          : 1.0;
                      return Transform.scale(
                        scale: pulse,
                        child: _AnimatedTitle(
                          letters: _letters,
                          progress: _assembleController.value,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _taglineController,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.35),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _taglineController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: Text(
                        _tagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _PulseLoader(animation: _loaderController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterFlight {
  const _LetterFlight({
    required this.char,
    required this.origin,
    required this.delay,
    this.isSpace = false,
  });

  final String char;
  final Offset origin;
  final double delay;
  final bool isSpace;
}

class _AnimatedTitle extends StatelessWidget {
  const _AnimatedTitle({
    required this.letters,
    required this.progress,
  });

  final List<_LetterFlight> letters;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final letter in letters)
              _FlyingLetter(
                letter: letter,
                progress: progress,
                maxWidth: width,
              ),
          ],
        );
      },
    );
  }
}

class _FlyingLetter extends StatelessWidget {
  const _FlyingLetter({
    required this.letter,
    required this.progress,
    required this.maxWidth,
  });

  final _LetterFlight letter;
  final double progress;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (letter.isSpace) {
      return const SizedBox(width: 14);
    }

    final localProgress = ((progress - letter.delay) / (1 - letter.delay))
        .clamp(0.0, 1.0);
    final curve = Curves.easeOutBack.transform(localProgress);

    final dx = letter.origin.dx * maxWidth * 0.42 * (1 - curve);
    final dy = letter.origin.dy * 180 * (1 - curve);
    final scale = 0.35 + (0.65 * curve);
    final opacity = (localProgress * 1.4).clamp(0.0, 1.0);
    final rotation = (1 - curve) * letter.origin.dx * 0.8;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Text(
              letter.char,
              style: const TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseLoader extends StatelessWidget {
  const _PulseLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Transform.scale(
                  scale: 0.55 +
                      (0.45 *
                          Curves.easeOut.transform(
                            ((animation.value + (i * 0.22)) % 1.0),
                          )),
                  child: Opacity(
                    opacity: (1 - ((animation.value + (i * 0.22)) % 1.0))
                        .clamp(0.0, 0.55),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.75),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.55),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glowRadius = size.shortestSide * (0.18 + (progress * 0.08));

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.18 * progress),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );

    canvas.drawCircle(center, glowRadius, paint);

    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 3; i++) {
      final angle = (progress * math.pi * 2) + (i * math.pi * 2 / 3);
      final radius = glowRadius * 1.35;
      final dot = center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.55);
      canvas.drawCircle(dot, 3.5, orbitPaint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FloatingIconsPainter extends CustomPainter {
  _FloatingIconsPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 8; i++) {
      final phase = (t + i * 0.11) % 1.0;
      final x = size.width * (0.1 + (i * 0.11) % 0.8);
      final baseY = 0.12 + (i % 4) * 0.2;
      final y = size.height * (baseY + math.sin(phase * math.pi * 2) * 0.04);
      final radius = 4.0 + (i % 3) * 2.5;
      final opacity = (0.12 + math.sin(phase * math.pi * 2) * 0.08).clamp(0.06, 0.22);

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingIconsPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
