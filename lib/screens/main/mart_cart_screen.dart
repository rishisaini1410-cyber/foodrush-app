import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/food_order.dart';
import '../../providers/location_provider.dart';
import '../../providers/mart_cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/checkout/address_selector.dart';
import '../../widgets/checkout/bill_summary.dart';
import '../../widgets/checkout/payment_selector.dart';
import 'order_success_screen.dart';

/// Full RushMart checkout — address, bill, payment mode and order placement so
/// grocery orders flow exactly like food orders (history + tracking included).
class MartCartScreen extends StatefulWidget {
  const MartCartScreen({super.key});

  @override
  State<MartCartScreen> createState() => _MartCartScreenState();
}

class _MartCartScreenState extends State<MartCartScreen> {
  bool _isPaying = false;

  Future<void> _placeOrder(MartCartProvider mart) async {
    if (mart.lines.isEmpty) return;
    final profileProvider = context.read<ProfileProvider>();
    final locationProvider = context.read<LocationProvider>();
    final orderProvider = context.read<OrderProvider>();
    final navigator = Navigator.of(context);

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2));

    final address = locationProvider.displayAddress;
    final order = FoodOrder(
      id: 'mart-${DateTime.now().millisecondsSinceEpoch}',
      restaurantName: MartCartProvider.vendorName,
      items: mart.lines.map((line) => line.item.name).toList(),
      total: mart.total,
      orderedAt: DateTime.now(),
      deliveryAddress: address,
      status: 'Placed',
      orderType: 'mart',
      vendors: const [MartCartProvider.vendorName],
      paymentMode: mart.paymentMode,
      lines: mart.orderLines,
      subtotal: mart.subtotal,
      deliveryFee: mart.deliveryFee,
      packingFee: mart.handlingFee,
    );

    await profileProvider.addOrder(order);
    await locationProvider.setLastOrderAddress(address);
    await orderProvider.placeOrder(order);
    mart.clear();

    if (!mounted) return;
    setState(() => _isPaying = false);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mart = context.watch<MartCartProvider>();
    const accent = AppColors.martAccent;

    return Scaffold(
      backgroundColor: AppColors.martSoft,
      appBar: AppBar(
        title: const Text('RushMart cart', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.martSoft,
        elevation: 0,
      ),
      body: mart.lines.isEmpty
          ? const Center(
              child: Text('Mart cart khali hai. Grocery add karo.', style: TextStyle(color: AppColors.muted)),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text('Delivery to', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const AddressSelectorCard(accent: accent),
                  const SizedBox(height: 18),
                  const Text('RushMart — 10 min delivery',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  ...mart.lines.map((line) => _martTile(line, mart)),
                  const SizedBox(height: 16),
                  const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  PaymentSelectorCard(
                    selectedId: mart.paymentMode,
                    onChanged: mart.setPaymentMode,
                    accent: accent,
                  ),
                  const SizedBox(height: 24),
                  BillSummaryCard(
                    rows: [
                      BillRow('Item subtotal', mart.subtotal),
                      BillRow('Delivery fee', mart.deliveryFee),
                      BillRow('Handling fee', mart.handlingFee),
                    ],
                    total: mart.total,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isPaying ? null : () => _placeOrder(mart),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isPaying
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Pay ₹${mart.total} • Place order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _martTile(MartCartLine line, MartCartProvider mart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: line.item.color.withValues(alpha: 0.15),
            child: Icon(line.item.icon, color: line.item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('${line.item.unit} • ₹${line.item.price}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(onPressed: () => mart.changeQty(line.item.id, -1), icon: const Icon(Icons.remove)),
          Text('${line.qty}', style: const TextStyle(fontWeight: FontWeight.w900)),
          IconButton(onPressed: () => mart.changeQty(line.item.id, 1), icon: const Icon(Icons.add)),
        ],
      ),
    );
  }
}
