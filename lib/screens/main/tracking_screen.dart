import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/order_provider.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderState = context.watch<OrderProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Live tracking', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!orderState.hasOrder)
              const Expanded(
                child: Center(
                  child: Text('Koi active order nahi hai.', style: TextStyle(color: AppColors.muted)),
                ),
              )
            else ...[
              Text('Current status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderState.stageLabel, style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(orderState.statusLabel, style: const TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 18),
                    LinearProgressIndicator(value: orderState.progress, color: accent, backgroundColor: accent.withValues(alpha: 0.15)),
                    const SizedBox(height: 18),
                    const Text('Delivery route', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _MapProgress(progress: orderState.progress, accent: accent),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stageDot('Confirm', orderState.progress > 0.0, accent),
                        _stageDot('Prep', orderState.progress >= 0.25, accent),
                        _stageDot('Pickup', orderState.progress >= 0.5, accent),
                        _stageDot('Done', orderState.progress >= 1.0, accent),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapProgress extends StatelessWidget {
  const _MapProgress({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final markerLeft = (constraints.maxWidth - 36) * progress;
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 6, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4))),
                      Container(height: 6, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: markerLeft,
                top: 70,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 8),
                    const Text('Rider', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _stageDot(String label, bool active, Color accent) {
  return Column(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: active ? accent : AppColors.line,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ],
  );
}
