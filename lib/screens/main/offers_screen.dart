import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/scratch_voucher_card.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AppProvider>().activeMode == 'veg'
        ? AppColors.vegAccent
        : AppColors.nonVegAccent;
    final vouchers = context.watch<ProfileProvider>().vouchers;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Offers & Rewards', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _couponCard(context, 'RUSH50', '50% off on your order', accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _couponCard(context, 'FREEDEL', 'Free delivery above ?299', accent),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Scratch & unlock',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...vouchers.map(
            (voucher) => ScratchVoucherCard(
              voucher: voucher,
              accent: accent,
              onScratched: () {
                context.read<ProfileProvider>().scratchVoucher(voucher.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voucher unlocked!')), 
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly AI Cart',
                  style: TextStyle(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pre-scheduled meal templates for the week. Add now and let Food Rush suggest your next tasty combo.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _mealChip('Monday Thali'),
                    _mealChip('Taco Tuesday'),
                    _mealChip('Wellness Bowl'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: 'RUSH50'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AI cart template added to your plan')),
                      );
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  child: const Text('Schedule weekly meals'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _couponCard(BuildContext context, String code, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            code,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$code copied to clipboard')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: const Text('Copy code'),
          ),
        ],
      ),
    );
  }

  Widget _mealChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
