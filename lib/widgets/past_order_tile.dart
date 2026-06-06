import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/food_order.dart';

class PastOrderTile extends StatelessWidget {
  final FoodOrder order;
  final int serial;
  final Color accent;
  final VoidCallback? onReorder;
  final VoidCallback? onInvoice;

  const PastOrderTile({
    super.key,
    required this.order,
    required this.serial,
    required this.accent,
    this.onReorder,
    this.onInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${order.orderedAt.day}/${order.orderedAt.month}/${order.orderedAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$serial',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            order.vendorSummary,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (order.isMart) ...[
                          const SizedBox(width: 6),
                          _badge('Mart', accent),
                        ] else if (order.isMultiVendor) ...[
                          const SizedBox(width: 6),
                          _badge('${order.vendorNames.length} stores', accent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.itemsSummary,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${order.total}',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onReorder != null || onInvoice != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onReorder != null)
                  FilledButton(
                    onPressed: onReorder,
                    style: FilledButton.styleFrom(backgroundColor: accent),
                    child: const Text('Reorder'),
                  ),
                if (onReorder != null && onInvoice != null)
                  const SizedBox(width: 10),
                if (onInvoice != null)
                  OutlinedButton(
                    onPressed: onInvoice,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: const Text('Invoice'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
