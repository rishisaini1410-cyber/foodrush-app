import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/voucher.dart';

class ScratchVoucherCard extends StatefulWidget {
  final Voucher voucher;
  final Color accent;
  final VoidCallback onScratched;

  const ScratchVoucherCard({
    super.key,
    required this.voucher,
    required this.accent,
    required this.onScratched,
  });

  @override
  State<ScratchVoucherCard> createState() => _ScratchVoucherCardState();
}

class _ScratchVoucherCardState extends State<ScratchVoucherCard> {
  final List<Offset> _scratches = [];

  @override
  Widget build(BuildContext context) {
    final v = widget.voucher;
    final revealed = v.scratched || _scratches.length > 18;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [widget.accent, widget.accent.withValues(alpha: 0.75)],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accent.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    v.discountText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (revealed) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        v.code,
                        style: TextStyle(
                          color: widget.accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Valid till ${_formatDate(v.validUntil)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ] else
                    Text(
                      'Scratch karke code reveal karo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (!revealed)
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (d) {
                    setState(() {
                      _scratches.add(d.localPosition);
                      if (_scratches.length > 18) {
                        widget.onScratched();
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      _scratches.add(const Offset(80, 50));
                      _scratches.add(const Offset(120, 70));
                      _scratches.add(const Offset(160, 40));
                    });
                    if (_scratches.length > 18) widget.onScratched();
                  },
                  child: CustomPaint(
                    painter: _ScratchOverlayPainter(
                      scratches: _scratches,
                      accent: widget.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _ScratchOverlayPainter extends CustomPainter {
  _ScratchOverlayPainter({required this.scratches, required this.accent});

  final List<Offset> scratches;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = AppColors.yellow.withValues(alpha: 0.95);
    canvas.drawRect(Offset.zero & size, base);

    final text = TextPainter(
      text: const TextSpan(
        text: 'SCRATCH HERE',
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset((size.width - text.width) / 2, size.height / 2 - 20),
    );

    final clear = Paint()..blendMode = BlendMode.clear;
    for (final point in scratches) {
      canvas.drawCircle(point, 22, clear);
      canvas.drawCircle(
        point + const Offset(8, 4),
        14,
        clear,
      );
    }

    if (scratches.isEmpty) {
      final sparkle = Paint()
        ..color = accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 6; i++) {
        final angle = i * math.pi / 3;
        final cx = size.width / 2 + math.cos(angle) * 40;
        final cy = size.height / 2 + 30 + math.sin(angle) * 20;
        canvas.drawCircle(Offset(cx, cy), 4, sparkle);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchOverlayPainter oldDelegate) {
    return oldDelegate.scratches.length != scratches.length;
  }
}
