import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/cart_line.dart';
import '../../models/food_order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/checkout/address_selector.dart';
import '../../widgets/checkout/bill_summary.dart';
import '../../widgets/checkout/payment_selector.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController _specialCtrl;
  late final TextEditingController _deliveryCtrl;
  late final TextEditingController _couponCtrl;
  late final TextEditingController _customTipCtrl;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _specialCtrl = TextEditingController(text: cart.specialInstructions);
    _deliveryCtrl = TextEditingController(text: cart.deliveryInstructions);
    _couponCtrl = TextEditingController(text: cart.couponCode);
    _customTipCtrl = TextEditingController(text: cart.tip > 0 ? cart.tip.toString() : '');
  }

  @override
  void dispose() {
    _specialCtrl.dispose();
    _deliveryCtrl.dispose();
    _couponCtrl.dispose();
    _customTipCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (cart.lines.isEmpty) return;
    final profileProvider = context.read<ProfileProvider>();
    final locationProvider = context.read<LocationProvider>();
    final orderProvider = context.read<OrderProvider>();
    final navigator = Navigator.of(context);

    setState(() => _isPaying = true);
    await Future.delayed(const Duration(seconds: 2));

    final address = locationProvider.displayAddress;
    final order = FoodOrder(
      id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
      restaurantName: cart.vendorNames.isNotEmpty ? cart.vendorNames.first : 'Food Rush',
      items: cart.lines.map((line) => line.item.name).toList(),
      total: cart.total,
      orderedAt: DateTime.now(),
      deliveryAddress: address,
      status: 'Placed',
      orderType: 'food',
      vendors: cart.vendorNames,
      paymentMode: cart.paymentMode,
      lines: cart.orderLines,
      subtotal: cart.subtotal,
      taxes: cart.gst,
      deliveryFee: cart.deliveryFee,
      packingFee: cart.packingFee,
      discount: cart.discount,
      tip: cart.tip,
    );

    await profileProvider.addOrder(order);
    await locationProvider.setLastOrderAddress(address);
    await orderProvider.placeOrder(order);
    cart.clear();

    if (!mounted) return;
    setState(() => _isPaying = false);
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Your cart', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: cart.lines.isEmpty
          ? const Center(
              child: Text('Aapka cart abhi khali hai. Kuch add kijiye.', style: TextStyle(color: AppColors.muted)),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text('Delivery to', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  AddressSelectorCard(accent: accent),
                  const SizedBox(height: 18),
                  if (cart.isMultiVendor) _multiVendorBanner(cart, accent),
                  ..._vendorGroups(cart, accent),
                  const SizedBox(height: 8),
                  _sectionTitle('Special instructions'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _specialCtrl,
                    maxLines: 2,
                    onChanged: cart.setSpecialInstructions,
                    decoration: InputDecoration(
                      hintText: 'Make it spicy, no onion, extra sauce...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deliveryCtrl,
                    maxLines: 2,
                    onChanged: cart.setDeliveryInstructions,
                    decoration: InputDecoration(
                      hintText: 'Don\'t ring the bell, leave at reception...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Promo code'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter code like RUSH50',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          cart.setCoupon(_couponCtrl.text.trim());
                        },
                        style: FilledButton.styleFrom(backgroundColor: accent),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Tip your rider'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _tipChip(cart, 20, accent),
                      _tipChip(cart, 30, accent),
                      _tipChip(cart, 50, accent),
                      _customTipField(cart, accent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _cutleryOption(cart, accent),
                  const SizedBox(height: 14),
                  Text('You saved ${cart.plasticSaved}g plastic today', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  _sectionTitle('Payment'),
                  const SizedBox(height: 10),
                  PaymentSelectorCard(
                    selectedId: cart.paymentMode,
                    onChanged: cart.setPaymentMode,
                    accent: accent,
                  ),
                  const SizedBox(height: 24),
                  BillSummaryCard(rows: _billRows(cart), total: cart.total),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isPaying ? null : () => _placeOrder(cart),
                      style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isPaying
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Pay ₹${cart.total} • Place order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<BillRow> _billRows(CartProvider cart) {
    return [
      BillRow('Item subtotal', cart.subtotal),
      BillRow('GST (5%)', cart.gst),
      BillRow('Delivery fee', cart.deliveryFee),
      BillRow('Packaging', cart.packingFee),
      if (cart.discount > 0) BillRow('Discount', cart.discount, isDiscount: true),
      if (cart.tip > 0) BillRow('Rider tip', cart.tip),
    ];
  }

  Widget _multiVendorBanner(CartProvider cart, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.storefront_rounded, color: accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Multi-restaurant order — ${cart.vendorNames.length} restaurants ek saath',
              style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _vendorGroups(CartProvider cart, Color accent) {
    final groups = cart.linesByVendor;
    final widgets = <Widget>[];
    groups.forEach((vendor, lines) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.restaurant_rounded, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(vendor, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              ),
            ],
          ),
        ),
      );
      widgets.addAll(lines.map((line) => _lineTile(line, accent, cart)));
    });
    return widgets;
  }

  Widget _lineTile(CartLine line, Color accent, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(line.item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text('₹${line.unitPrice}', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          if (line.size != 'Regular') Text('Size: ${line.size}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          if (line.toppings.isNotEmpty) Text('Extras: ${line.toppings.join(', ')}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          if (line.spiceLevel.isNotEmpty) Text('Spice: ${line.spiceLevel}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(onPressed: () => cart.changeQty(line.id, -1), icon: const Icon(Icons.remove)),
              Text('${line.qty}', style: const TextStyle(fontWeight: FontWeight.w900)),
              IconButton(onPressed: () => cart.changeQty(line.id, 1), icon: const Icon(Icons.add)),
              const Spacer(),
              Text('₹${line.lineTotal}', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900));
  }

  Widget _tipChip(CartProvider cart, int value, Color accent) {
    final active = cart.tip == value;
    return ChoiceChip(
      label: Text('₹$value'),
      selected: active,
      onSelected: (_) {
        cart.setTip(value);
        _customTipCtrl.text = '';
      },
      selectedColor: accent,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(color: active ? Colors.white : AppColors.muted, fontWeight: FontWeight.w700),
    );
  }

  Widget _customTipField(CartProvider cart, Color accent) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: _customTipCtrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Custom',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
        ),
        onSubmitted: (value) {
          final amount = int.tryParse(value) ?? 0;
          cart.setTip(amount);
        },
      ),
    );
  }

  Widget _cutleryOption(CartProvider cart, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No plastic cutlery', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Yes, I do not need disposable cutlery. Save the planet!', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: cart.noCutlery,
            activeThumbColor: accent,
            onChanged: cart.setNoCutlery,
          ),
        ],
      ),
    );
  }
}
