import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/location_provider.dart';

/// Delivery address card with a "Change" action that opens a picker over the
/// user's saved locations and detected current location.
class AddressSelectorCard extends StatelessWidget {
  const AddressSelectorCard({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.displayLabel,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  loc.displayAddress,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openPicker(context, loc, accent),
            child: Text('Change', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _openPicker(BuildContext context, LocationProvider loc, Color accent) {
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
                const Text('Select delivery address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.my_location_rounded, color: accent),
                  title: const Text('Use current location',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(loc.hasCurrentLocation
                      ? loc.currentLocationAddress!
                      : 'Detect my location'),
                  trailing: loc.detecting
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : null,
                  onTap: () async {
                    if (loc.hasCurrentLocation) {
                      await loc.selectLocation(LocationProvider.currentLocationId);
                    } else {
                      await loc.detectCurrentLocation();
                    }
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
                const Divider(),
                ...loc.savedLocations.map(
                  (saved) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_iconForLabel(saved.label), color: accent),
                    title: Text(saved.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(saved.displayLine),
                    trailing: loc.selectedLocationId == saved.id
                        ? Icon(Icons.check_circle_rounded, color: accent)
                        : null,
                    onTap: () async {
                      await loc.selectLocation(saved.id);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
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

  IconData _iconForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('home')) return Icons.home_rounded;
    if (l.contains('work') || l.contains('office')) return Icons.work_rounded;
    return Icons.place_rounded;
  }
}
