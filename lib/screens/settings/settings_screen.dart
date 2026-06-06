import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/mart_cart_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _orderUpdates = true;
  bool _promoOffers = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool('settings_notifications') ?? true;
      _orderUpdates = prefs.getBool('settings_orderUpdates') ?? true;
      _promoOffers = prefs.getBool('settings_promoOffers') ?? true;
      _language = prefs.getString('settings_language') ?? 'English';
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final app = context.watch<AppProvider>();
    final profile = context.watch<ProfileProvider>();
    final user = profile.user;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('Account'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  child: Icon(Icons.person_rounded, color: accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Food Rush customer',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? user?.phone ?? 'Guest account',
                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel('Preferences'),
          _switchTile(
            icon: Icons.notifications_rounded,
            title: 'Push notifications',
            subtitle: 'Offers, reminders & alerts',
            value: _notifications,
            accent: accent,
            onChanged: (v) {
              setState(() => _notifications = v);
              _setBool('settings_notifications', v);
            },
          ),
          _switchTile(
            icon: Icons.local_shipping_rounded,
            title: 'Order updates',
            subtitle: 'Live status of your orders',
            value: _orderUpdates,
            accent: accent,
            onChanged: (v) {
              setState(() => _orderUpdates = v);
              _setBool('settings_orderUpdates', v);
            },
          ),
          _switchTile(
            icon: Icons.local_offer_rounded,
            title: 'Offers & promos',
            subtitle: 'Personalised deals',
            value: _promoOffers,
            accent: accent,
            onChanged: (v) {
              setState(() => _promoOffers = v);
              _setBool('settings_promoOffers', v);
            },
          ),
          _switchTile(
            icon: Icons.eco_rounded,
            title: 'Default to Veg mode',
            subtitle: 'Show vegetarian food first',
            value: app.activeMode == 'veg',
            accent: accent,
            onChanged: (v) => app.setMode(v ? 'veg' : 'nonveg'),
          ),
          _switchTile(
            icon: Icons.phone_locked_rounded,
            title: 'Call masking',
            subtitle: 'Hide your number from riders',
            value: profile.callMasking,
            accent: accent,
            onChanged: (v) => profile.setCallMasking(v),
          ),
          const SizedBox(height: 20),
          _sectionLabel('General'),
          _actionTile(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: _language,
            accent: accent,
            onTap: _pickLanguage,
          ),
          _actionTile(
            icon: Icons.remove_shopping_cart_rounded,
            title: 'Clear cart',
            subtitle: 'Empty food & mart carts',
            accent: accent,
            onTap: () {
              context.read<CartProvider>().clear();
              context.read<MartCartProvider>().clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart clear ho gaya')),
              );
            },
          ),
          _actionTile(
            icon: Icons.info_outline_rounded,
            title: 'About Food Rush',
            subtitle: 'Version 1.0.0',
            accent: accent,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Food Rush',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Indian cravings, delivered with style.',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        const langs = ['English', 'हिन्दी', 'తెలుగు', 'தமிழ்', 'मराठी'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs
                .map((l) => ListTile(
                      title: Text(l),
                      trailing: _language == l ? const Icon(Icons.check_rounded) : null,
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('settings_language', l);
                        if (!mounted) return;
                        setState(() => _language = l);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final navigator = Navigator.of(context);
    final profile = context.read<ProfileProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Aapko dobara login karna padega.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService().clearSession();
    profile.clear();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.muted)),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color accent,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: accent, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Text(
          trailing ?? '',
          style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
        ),
        onTap: onTap,
      ),
    );
  }
}
