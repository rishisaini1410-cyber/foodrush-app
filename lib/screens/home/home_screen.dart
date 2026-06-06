import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/restaurant.dart';
import '../../providers/app_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../providers/mart_cart_provider.dart';
import '../../widgets/animated_promo_hero.dart';
import '../../widgets/food_rush_logo.dart';
import '../../widgets/home_location_bar.dart';
import '../../widgets/popular_restaurant_card.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/rush_mart_section.dart';
import '../main/cart_screen.dart';
import '../main/mart_cart_screen.dart';
import '../profile/profile_screen.dart';
import '../restaurant/restaurant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _martSearchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getSessionUser();
    if (!mounted || user == null) return;
    await Future.wait([
      context.read<LocationProvider>().initForUser(user.id),
      context.read<ProfileProvider>().initForUser(user),
    ]);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _martSearchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Color _accent(AppProvider app) {
    if (app.isRushMartMode) return AppColors.martAccent;
    return app.activeMode == 'veg' ? AppColors.vegAccent : AppColors.nonVegAccent;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final cart = context.watch<CartProvider>();
    final copy = app.copy;
    final accent = _accent(app);
    final popular = app.popularRestaurants;
    final nearby = app.restaurantsByDistance;
    final isFood = app.isFoodMode;

    return Scaffold(
      backgroundColor:
          isFood ? AppColors.paper : AppColors.martSoft,
      endDrawer: _cartDrawer(app, cart, accent),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: HomeLocationBar()),
                        _profileBtn(accent),
                        const SizedBox(width: 8),
                        _cartBtn(cart, accent),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: FoodRushLogo(size: 30),
                    ),
                    const SizedBox(height: 14),
                    if (isFood) _modeToggle(app, accent),
                    if (isFood) const SizedBox(height: 14),
                    AnimatedPromoHero(key: ValueKey(app.serviceMode)),
                    const SizedBox(height: 18),
                    if (isFood) ...[
                      Text(
                        copy.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        copy.text,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchCtrl,
                        onChanged: app.setQuery,
                        decoration: InputDecoration(
                          hintText: copy.search,
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: app.filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f = app.filters[i];
                            final active = f == app.activeFilter;
                            return FilterChip(
                              label: Text(f),
                              selected: active,
                              onSelected: (_) => app.setFilter(f),
                              selectedColor: accent,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: active ? Colors.white : AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(
                                color: active ? accent : AppColors.line,
                              ),
                            );
                          },
                        ),
                      ),
                    ] else
                      RushMartSection(searchController: _martSearchCtrl),
                  ],
                ),
              ),
            ),
            if (isFood && popular.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: accent, size: 22),
                      const SizedBox(width: 6),
                      const Text(
                        'Popular Restaurants',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Top rated',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: popular.length,
                    itemBuilder: (_, i) => PopularRestaurantCard(
                      restaurant: popular[i],
                      mode: app.activeMode,
                      onOpen: () => _openRestaurant(popular[i]),
                    ),
                  ),
                ),
              ),
            ],
            if (isFood)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
                  child: Row(
                    children: [
                      Icon(Icons.near_me_rounded, color: accent, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Nearby — Short to Long',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isFood && nearby.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Koi restaurant nahi mila.\nSearch ya filter change karo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              )
            else if (isFood)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => RestaurantCard(
                      restaurant: nearby[i],
                      mode: app.activeMode,
                      onOpen: () => _openRestaurant(nearby[i]),
                    ),
                    childCount: nearby.length,
                  ),
                ),
              ),
            if (!isFood)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _modeToggle(AppProvider app, Color accent) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _modeChip('Veg Mode', 'veg', app, accent),
          _modeChip('Non-Veg', 'nonveg', app, accent),
        ],
      ),
    );
  }

  Expanded _modeChip(
    String label,
    String mode,
    AppProvider app,
    Color accent,
  ) {
    final active = app.activeMode == mode;
    final color = mode == 'veg' ? AppColors.vegAccent : AppColors.nonVegAccent;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          app.setMode(mode);
          context.read<CartProvider>().cleanForMode(mode);
          _searchCtrl.clear();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                mode == 'veg' ? Icons.eco_rounded : Icons.restaurant_rounded,
                size: 16,
                color: active ? Colors.white : AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: active ? Colors.white : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileBtn(Color accent) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.person_rounded, color: accent, size: 22),
        ),
      ),
    );
  }

  Widget _cartBtn(CartProvider cart, Color accent) {
    final app = context.watch<AppProvider>();
    final mart = context.watch<MartCartProvider>();
    final count = app.isRushMartMode ? mart.count : cart.count;

    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Scaffold.of(context).openEndDrawer(),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                app.isRushMartMode
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _openRestaurant(Restaurant r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RestaurantScreen(restaurant: r)),
    );
  }

  Widget _cartDrawer(AppProvider app, CartProvider cart, Color accent) {
    final mart = context.watch<MartCartProvider>();
    final isMart = app.isRushMartMode;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMart ? 'RushMart cart' : 'Your cart',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isMart
                    ? _martCartList(mart)
                    : _foodCartList(cart),
              ),
              Text(
                'Total: ₹${isMart ? mart.grandTotal : cart.total}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isMart
                      ? (mart.count == 0
                          ? null
                          : () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MartCartScreen()),
                              );
                            })
                      : (cart.count == 0
                          ? null
                          : () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CartScreen()),
                              );
                            }),
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  child: Text(isMart ? 'Checkout mart' : 'Proceed to checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _foodCartList(CartProvider cart) {
    if (cart.lines.isEmpty) {
      return const Center(
        child: Text(
          'Basket empty hai.\nKuch tasty add karo.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: cart.lines.length,
      itemBuilder: (_, i) {
        final line = cart.lines[i];
        return ListTile(
          title: Text(line.item.name),
          subtitle: Text(
            '${line.restaurantName} • ₹${line.item.price}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => cart.changeQty(line.item.id, -1),
                icon: const Icon(Icons.remove),
              ),
              Text('${line.qty}'),
              IconButton(
                onPressed: () => cart.changeQty(line.item.id, 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _martCartList(MartCartProvider mart) {
    if (mart.lines.isEmpty) {
      return const Center(
        child: Text(
          'Mart cart empty hai.\nGrocery add karo.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: mart.lines.length,
      itemBuilder: (_, i) {
        final line = mart.lines[i];
        return ListTile(
          leading: Icon(line.item.icon, color: line.item.color),
          title: Text(line.item.name),
          subtitle: Text('${line.item.unit} • ₹${line.item.price}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => mart.changeQty(line.item.id, -1),
                icon: const Icon(Icons.remove),
              ),
              Text('${line.qty}'),
              IconButton(
                onPressed: () => mart.changeQty(line.item.id, 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        );
      },
    );
  }
}
