import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/saved_location.dart';
import '../../providers/location_provider.dart';

class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text(
          'Delivery location',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (loc.lastOrderAddress != null) ...[
            const Text(
              'Last order location',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _LocationTile(
              icon: Icons.receipt_long_rounded,
              title: 'Previous order',
              subtitle: loc.lastOrderAddress!,
              selected: false,
              accent: accent,
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Saved locations',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          _CurrentLocationCard(loc: loc, accent: accent),
          const SizedBox(height: 12),
          ...loc.savedLocations.map(
            (saved) => _SavedLocationTile(
              location: saved,
              selected: loc.selectedLocationId == saved.id,
              accent: accent,
              onSelect: () {
                loc.selectLocation(saved.id);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.loc, required this.accent});

  final LocationProvider loc;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: loc.selectedLocationId == LocationProvider.currentLocationId
              ? accent
              : AppColors.line,
          width: loc.selectedLocationId == LocationProvider.currentLocationId
              ? 2
              : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(Icons.my_location_rounded, color: accent, size: 22),
            ),
            title: const Text(
              'Current location',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: loc.detecting
                ? const Text('Detecting location...')
                : Text(
                    loc.hasCurrentLocation
                        ? loc.currentLocationAddress!
                        : 'Abhi detect nahi hui',
                    style: const TextStyle(fontSize: 13),
                  ),
            trailing: loc.selectedLocationId ==
                    LocationProvider.currentLocationId
                ? Icon(Icons.check_circle_rounded, color: accent)
                : null,
            onTap: loc.hasCurrentLocation
                ? () {
                    loc.selectLocation(LocationProvider.currentLocationId);
                    Navigator.pop(context);
                  }
                : null,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: loc.detecting
                    ? null
                    : () async {
                        await loc.detectCurrentLocation();
                        if (context.mounted) Navigator.pop(context);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: loc.detecting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      )
                    : const Icon(Icons.gps_fixed_rounded, size: 20),
                label: Text(
                  loc.hasCurrentLocation
                      ? 'Refresh current location'
                      : 'Use my current location',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLocationTile extends StatelessWidget {
  const _SavedLocationTile({
    required this.location,
    required this.selected,
    required this.accent,
    required this.onSelect,
  });

  final SavedLocation location;
  final bool selected;
  final Color accent;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _LocationTile(
        icon: Icons.location_on_rounded,
        title: location.label,
        subtitle: location.displayLine,
        selected: selected,
        accent: accent,
        onTap: onSelect,
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : AppColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
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
              if (selected)
                Icon(Icons.check_circle_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
