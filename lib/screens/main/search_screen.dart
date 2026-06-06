import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/restaurants_data.dart';
import '../../models/restaurant.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant/restaurant_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _vegOnly = false;
  bool _rating4 = false;
  bool _fastDelivery = false;
  bool _jain = false;

  List<Restaurant> get _results {
    final q = _searchCtrl.text.trim().toLowerCase();
    return allRestaurants.where((restaurant) {
      if (_vegOnly && restaurant.diet != 'veg') return false;
      if (_rating4 && restaurant.ratingValue < 4.0) return false;
      if (_fastDelivery && restaurant.time.contains('min') && int.tryParse(restaurant.time.split('-').first) != null) {
        final minutes = int.tryParse(restaurant.time.split('-').first) ?? 99;
        if (minutes > 25) return false;
      }
      if (_jain && !restaurant.tags.any((tag) => tag.toLowerCase().contains('jain'))) return false;
      if (q.isEmpty) return true;
      final searchable = '${restaurant.name} ${restaurant.category} ${restaurant.zone} ${restaurant.tags.join(' ')}'.toLowerCase();
      return searchable.contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.red;
    final results = _results;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.paper,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search restaurants, dishes or cuisines',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('Veg Only', _vegOnly, accent, () {
                  setState(() => _vegOnly = !_vegOnly);
                }),
                _filterChip('Rating 4.0+', _rating4, accent, () {
                  setState(() => _rating4 = !_rating4);
                }),
                _filterChip('Fast Delivery', _fastDelivery, accent, () {
                  setState(() => _fastDelivery = !_fastDelivery);
                }),
                _filterChip('Jain Food', _jain, accent, () {
                  setState(() => _jain = !_jain);
                }),
              ],
            ),
            const SizedBox(height: 16),
            if (_searchCtrl.text.isEmpty)
              Wrap(
                spacing: 10,
                children: [
                  'Pizza',
                  'Biryani',
                  'Healthy',
                  'Thali',
                  'Fast food',
                ].map((label) {
                  return ActionChip(
                    label: Text(label),
                    onPressed: () {
                      _searchCtrl.text = label;
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'Koi result nahi mila. Try a different search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final restaurant = results[index];
                        return RestaurantCard(
                          restaurant: restaurant,
                          mode: restaurant.diet,
                          onOpen: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantScreen(restaurant: restaurant),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, Color accent, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: accent,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.muted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
