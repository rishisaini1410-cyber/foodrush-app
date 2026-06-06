import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/food_order.dart';
import '../../models/order_line.dart';
import '../../models/payment_method.dart';
import 'tracking_screen.dart';

/// Post-payment confirmation: what was ordered (vendor-wise), where it's going,
/// the payment mode and the grand total — Zomato/Swiggy style.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final byVendor = <String, List<OrderLine>>{};
    for (final line in order.lines) {
      byVendor.putIfAbsent(line.vendor, () => []).add(line);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: Icon(Icons.check_circle_rounded, color: accent, size: 56),
                  ),
                  const SizedBox(height: 14),
                  const Text('Order placed!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Order ID: ${order.id}',
                      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading(order.isMart ? 'Your mart items' : 'Your order', accent),
                  const SizedBox(height: 10),
                  for (final entry in byVendor.entries) ...[
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    ...entry.value.map(
                      (l) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${l.qty} x ${l.name}'
                                '${l.options.isNotEmpty ? ' (${l.options})' : ''}',
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ),
                            Text('₹${l.lineTotal}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _heading('Delivering to', accent),
                  const SizedBox(height: 6),
                  Text(order.deliveryAddress, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(PaymentMethods.byId(order.paymentMode).icon, size: 18, color: accent),
                      const SizedBox(width: 8),
                      Text(
                        'Paid via ${PaymentMethods.byId(order.paymentMode).label}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text('₹${order.total}',
                          style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.delivery_dining_rounded),
                label: const Text('Track order'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Back to home', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }

  Widget _heading(String text, Color accent) {
    return Text(text, style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 15));
  }
}
