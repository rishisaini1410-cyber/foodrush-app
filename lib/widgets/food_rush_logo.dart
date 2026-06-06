import 'package:flutter/material.dart';

class FoodRushLogo extends StatelessWidget {
  const FoodRushLogo({
    super.key,
    this.size = 36,
    this.compact = false,
  });

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 8,
          height: size + 8,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF144E2C), Color(0xFFF16F24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF16F24).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        if (!compact) ...[
          SizedBox(width: size * 0.28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF144E2C), Color(0xFFF16F24)],
                ).createShader(bounds),
                child: Text(
                  'Food Rush',
                  style: TextStyle(
                    fontSize: size * 0.72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                'Crave. Click. Crunch.',
                style: TextStyle(
                  fontSize: size * 0.28,
                  color: const Color(0xFF6F6A62),
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
