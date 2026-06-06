import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/payment_method.dart';

/// Payment mode card with a picker over all supported methods
/// (UPI, card, net banking, wallet, cash on delivery).
class PaymentSelectorCard extends StatelessWidget {
  const PaymentSelectorCard({
    super.key,
    required this.selectedId,
    required this.onChanged,
    required this.accent,
  });

  final String selectedId;
  final ValueChanged<String> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final method = PaymentMethods.byId(selectedId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Icon(method.icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment mode',
                    style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(method.label, style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openPicker(context),
            child: Text('Change', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose payment mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                ...PaymentMethods.all.map(
                  (m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(m.icon, color: accent),
                    title: Text(m.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(m.subtitle),
                    trailing: selectedId == m.id
                        ? Icon(Icons.check_circle_rounded, color: accent)
                        : const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.muted),
                    onTap: () {
                      onChanged(m.id);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
