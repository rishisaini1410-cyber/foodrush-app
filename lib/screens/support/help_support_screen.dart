import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = <List<String>>[
    [
      'Mera order kab tak aayega?',
      'Order place hone ke baad Orders tab me live tracking dikhta hai. Normal '
          'delivery 30-40 min, RushMart 10 min me.',
    ],
    [
      'Main ek saath alag restaurants se order kar sakta hoon?',
      'Haan! Cart me alag-alag restaurants ke items add karo — sab vendor-wise '
          'group hoke ek hi order me chale jaate hain.',
    ],
    [
      'Payment ke kaunse options hain?',
      'UPI, Credit/Debit card, Net banking, Food Rush wallet aur Cash on '
          'delivery — checkout par choose kar sakte ho.',
    ],
    [
      'Refund kaise milega?',
      'Cancelled ya issue wale orders ka refund 3-5 working days me original '
          'payment method me aa jata hai.',
    ],
    [
      'Delivery address kaise change karu?',
      'Checkout screen par "Change" dabao aur saved address chuno ya current '
          'location detect karo.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hi, how can we help?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 6),
                Text('Hum 24x7 available hain.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _contactCard(context, Icons.chat_rounded, 'Live chat', 'Avg < 2 min', accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _contactCard(context, Icons.call_rounded, 'Call us', '1800-123-4567', accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _contactCard(context, Icons.email_rounded, 'Email', 'help@foodrush.in', accent),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Frequently asked', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _faqTile(faq[0], faq[1])),
          const SizedBox(height: 20),
          _linkTile(context, Icons.receipt_long_rounded, 'Order issues', 'Report a problem with an order', accent),
          _linkTile(context, Icons.shield_rounded, 'Safety', 'Safety toolkit & emergency help', accent),
          _linkTile(context, Icons.description_rounded, 'Terms & policies', 'Terms of use and privacy', accent),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _raiseTicket(context, accent),
              style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 16)),
              icon: const Icon(Icons.support_agent_rounded),
              label: const Text('Raise a ticket'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context, IconData icon, String title, String subtitle, Color accent) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title: $subtitle')),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 26),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(answer, style: const TextStyle(color: AppColors.muted, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkTile(BuildContext context, IconData icon, String title, String subtitle, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title — coming soon')),
        ),
      ),
    );
  }

  void _raiseTicket(BuildContext context, Color accent) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 18,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raise a support ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Apni problem describe karo...',
                  filled: true,
                  fillColor: AppColors.paper,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket raise ho gaya. Hum jaldi contact karenge.')),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: accent, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Submit ticket'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
