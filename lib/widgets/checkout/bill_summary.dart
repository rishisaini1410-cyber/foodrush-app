import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class BillRow {
  final String label;
  final int amount;
  final bool isDiscount;

  const BillRow(this.label, this.amount, {this.isDiscount = false});
}

/// Itemised bill card (subtotal, taxes, fees, discount, tip) ending in the
/// grand total — shared by food and mart checkout.
class BillSummaryCard extends StatelessWidget {
  const BillSummaryCard({
    super.key,
    required this.rows,
    required this.total,
    this.title = 'Bill details',
  });

  final List<BillRow> rows;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          ),
          const SizedBox(height: 14),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _row(
                r.label,
                r.isDiscount ? '-₹${r.amount}' : '₹${r.amount}',
                valueColor: r.isDiscount ? AppColors.green : null,
              ),
            ),
          ),
          const Divider(height: 14, thickness: 1),
          const SizedBox(height: 6),
          _row('Grand total', '₹$total', strong: true),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {bool strong = false, Color? valueColor}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: strong ? AppColors.ink : AppColors.muted,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
            fontSize: strong ? 16 : 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            fontSize: strong ? 16 : 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
