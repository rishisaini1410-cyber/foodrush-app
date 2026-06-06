import 'package:flutter/material.dart';

/// A checkout payment option (UPI, Card, Net Banking, Wallet, Cash on Delivery).
class PaymentMethod {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  const PaymentMethod({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class PaymentMethods {
  static const upi = PaymentMethod(
    id: 'upi',
    label: 'UPI',
    subtitle: 'GPay, PhonePe, Paytm & more',
    icon: Icons.account_balance_wallet_rounded,
  );

  static const card = PaymentMethod(
    id: 'card',
    label: 'Credit / Debit card',
    subtitle: 'Visa, Mastercard, RuPay',
    icon: Icons.credit_card_rounded,
  );

  static const netBanking = PaymentMethod(
    id: 'netbanking',
    label: 'Net banking',
    subtitle: 'All major banks',
    icon: Icons.account_balance_rounded,
  );

  static const wallet = PaymentMethod(
    id: 'wallet',
    label: 'Food Rush wallet',
    subtitle: 'Pay using your balance',
    icon: Icons.wallet_rounded,
  );

  static const cod = PaymentMethod(
    id: 'cod',
    label: 'Cash on delivery',
    subtitle: 'Pay when it arrives',
    icon: Icons.payments_rounded,
  );

  static const all = <PaymentMethod>[upi, card, netBanking, wallet, cod];

  static PaymentMethod byId(String id) =>
      all.firstWhere((m) => m.id == id, orElse: () => upi);
}
