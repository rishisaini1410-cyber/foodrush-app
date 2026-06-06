import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/past_order_tile.dart';
import '../../widgets/scratch_voucher_card.dart';
import 'past_orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showAllOrders = false;
  bool _showProfileDetails = false;
  bool _showFavourites = false;
  bool _showStatement = false;
  bool _showVouchers = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final app = context.watch<AppProvider>();
    final user = profile.user;
    final accent =
        app.activeMode == 'veg' ? AppColors.vegAccent : AppColors.nonVegAccent;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final previewOrders = profile.pastOrdersSorted;
    final visibleOrders =
        _showAllOrders ? previewOrders : previewOrders.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          _ProfileHeaderCard(
            name: user.name,
            email: user.email,
            phone: user.phone,
            expanded: _showProfileDetails,
            onTap: () =>
                setState(() => _showProfileDetails = !_showProfileDetails),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.favorite_rounded,
            title: 'Favourites',
            subtitle: '${profile.favorites.length} saved choices',
            accent: accent,
            expanded: _showFavourites,
            onTap: () => setState(() => _showFavourites = !_showFavourites),
            child: _showFavourites ? _FavouritesList(profile: profile) : null,
          ),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Account statement',
            subtitle: profile.statementPeriodLabel,
            accent: accent,
            expanded: _showStatement,
            onTap: () => setState(() => _showStatement = !_showStatement),
            child: _showStatement ? _StatementPanel(profile: profile, accent: accent) : null,
          ),
          _MenuTile(
            icon: Icons.train_rounded,
            title: 'Order food on train',
            subtitle: 'Coming soon',
            accent: accent,
            onTap: () => _showComingSoon(context, 'Order food on train'),
          ),
          _MenuTile(
            icon: Icons.card_giftcard_rounded,
            title: 'Vouchers',
            subtitle: '${profile.vouchers.length} available',
            accent: accent,
            expanded: _showVouchers,
            onTap: () => setState(() => _showVouchers = !_showVouchers),
            child: _showVouchers
                ? _VouchersList(profile: profile, accent: accent)
                : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Past orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              if (previewOrders.length > 4 && !_showAllOrders)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PastOrdersScreen(),
                      ),
                    );
                  },
                  child: Text('View all', style: TextStyle(color: accent)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...visibleOrders.asMap().entries.map(
                (e) => PastOrderTile(
                  order: e.value,
                  serial: e.key + 1,
                  accent: accent,
                ),
              ),
          if (previewOrders.length > 4)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  if (_showAllOrders) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PastOrdersScreen(),
                      ),
                    );
                  } else {
                    setState(() => _showAllOrders = true);
                  }
                },
                icon: Icon(
                  _showAllOrders
                      ? Icons.open_in_new_rounded
                      : Icons.expand_more_rounded,
                  color: accent,
                ),
                label: Text(
                  _showAllOrders ? 'Full history screen' : 'Show more',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Coming soon'),
        content: Text(
          '$feature jald hi Food Rush par available hoga. Stay tuned!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.expanded,
    required this.onTap,
  });

  final String name;
  final String? email;
  final String? phone;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF168557),
              Color(0xFFF5B335),
              Color(0xFFE84932),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.vegAccent.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        expanded ? 'Details niche' : 'Tap for full details',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 16),
              _DetailRow(Icons.phone_rounded, phone ?? 'Phone not added'),
              const SizedBox(height: 8),
              _DetailRow(Icons.email_rounded, email ?? 'Email not added'),
              const SizedBox(height: 8),
              _DetailRow(Icons.badge_rounded, 'Food Rush member'),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.expanded = false,
    this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool expanded;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accent.withValues(alpha: 0.12),
                      child: Icon(icon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.expand_less_rounded
                          : Icons.chevron_right_rounded,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _FavouritesList extends StatelessWidget {
  const _FavouritesList({required this.profile});
  final ProfileProvider profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: profile.favorites.map((f) {
          return ListTile(
            dense: true,
            leading: Icon(
              f.diet == 'veg' ? Icons.eco_rounded : Icons.restaurant_rounded,
              color: f.diet == 'veg' ? AppColors.vegAccent : AppColors.nonVegAccent,
            ),
            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${f.restaurantName} • ₹${f.price}'),
          );
        }).toList(),
      ),
    );
  }
}

class _StatementPanel extends StatelessWidget {
  const _StatementPanel({required this.profile, required this.accent});
  final ProfileProvider profile;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select duration',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StatementPeriod.values.map((p) {
              final selected = profile.statementPeriod == p;
              return ChoiceChip(
                label: Text(_periodLabel(p)),
                selected: selected,
                onSelected: (_) => profile.setStatementPeriod(p),
                selectedColor: accent,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.muted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(
                label: 'Orders',
                value: '${profile.statementOrders.length}',
                accent: accent,
              ),
              const SizedBox(width: 10),
              _StatBox(
                label: 'Total spent',
                value: '₹${profile.statementTotal}',
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...profile.statementOrders.take(5).map(
                (o) => ListTile(
                  dense: true,
                  title: Text(o.restaurantName),
                  subtitle: Text(
                    '${o.orderedAt.day}/${o.orderedAt.month}/${o.orderedAt.year}',
                  ),
                  trailing: Text(
                    '₹${o.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
              ),
          if (profile.statementOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Is duration mein koi order nahi.',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
        ],
      ),
    );
  }

  String _periodLabel(StatementPeriod p) {
    switch (p) {
      case StatementPeriod.thisMonth:
        return 'This month';
      case StatementPeriod.lastMonth:
        return 'Last month';
      case StatementPeriod.last3Months:
        return '3 months';
      case StatementPeriod.last6Months:
        return '6 months';
      case StatementPeriod.all:
        return 'All';
    }
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VouchersList extends StatelessWidget {
  const _VouchersList({required this.profile, required this.accent});
  final ProfileProvider profile;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: profile.vouchers.map((v) {
          return ScratchVoucherCard(
            voucher: v,
            accent: accent,
            onScratched: () => profile.scratchVoucher(v.id),
          );
        }).toList(),
      ),
    );
  }
}
