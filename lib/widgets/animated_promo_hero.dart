import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../data/promo_slides_data.dart';
import '../models/promo_slide.dart';
import '../providers/app_provider.dart';
import 'home_service_toggle.dart';

class AnimatedPromoHero extends StatefulWidget {
  const AnimatedPromoHero({super.key});

  @override
  State<AnimatedPromoHero> createState() => _AnimatedPromoHeroState();
}

class _AnimatedPromoHeroState extends State<AnimatedPromoHero>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _marqueeCtrl;
  Timer? _autoTimer;
  int _page = 0;
  int _categoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _marqueeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      final slides = _slidesFor(context.read<AppProvider>());
      if (slides.isEmpty) return;
      final next = (_page + 1) % slides.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  List<PromoSlide> _slidesFor(AppProvider app) =>
      app.isFoodMode ? foodPromoSlides : martPromoSlides;

  List<String> _categoriesFor(AppProvider app) =>
      app.isFoodMode ? foodOfferCategories : martOfferCategories;

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _marqueeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final slides = _slidesFor(app);
    final categories = _categoriesFor(app);
    final accent =
        app.isFoodMode ? AppColors.vegAccent : AppColors.martAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeServiceToggle(),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) {
                  setState(() {
                    _page = i;
                    _categoryIndex = i % categories.length;
                  });
                },
                itemCount: slides.length,
                itemBuilder: (_, i) => _PromoSlideCard(
                  slide: slides[i],
                  floatAnim: _floatCtrl,
                  pulseAnim: _pulseCtrl,
                ),
              ),
              ..._floatingDishes(slides[_page % slides.length], accent),
              Positioned(
                top: 10,
                left: 12,
                child: _LiveOffersBadge(pulse: _pulseCtrl, isMart: app.isRushMartMode),
              ),
              Positioned(
                bottom: 10,
                right: 12,
                child: _PageDots(count: slides.length, index: _page, accent: accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _MarqueeOffers(slides: slides, anim: _marqueeCtrl),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = categories[i];
              final active = i == _categoryIndex;
              final color = categoryColor(cat);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? color : AppColors.line,
                  ),
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
                child: Text(
                  cat,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _floatingDishes(PromoSlide slide, Color accent) {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          final t = (_floatCtrl.value + i * 0.33) % 1.0;
          final dx = 200.0 + i * 28.0 + math.sin(t * math.pi * 2) * 10;
          final dy = 24.0 + i * 36.0 + math.cos(t * math.pi * 2 + i) * 10;
          final scale = 0.85 + math.sin(t * math.pi * 2) * 0.08;
          return Positioned(
            left: dx,
            top: dy,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: _FloatingDishBubble(icon: slide.dishIcon, color: accent),
      );
    });
  }
}

class _PromoSlideCard extends StatelessWidget {
  const _PromoSlideCard({
    required this.slide,
    required this.floatAnim,
    required this.pulseAnim,
  });

  final PromoSlide slide;
  final Animation<double> floatAnim;
  final Animation<double> pulseAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([floatAnim, pulseAnim]),
      builder: (context, _) {
        final shimmer = 0.92 + pulseAnim.value * 0.08;
        return Transform.scale(
          scale: shimmer,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [slide.gradientStart, slide.gradientEnd],
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.gradientStart.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    slide.dishIcon,
                    size: 140,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 44, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          slide.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        slide.restaurant,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide.dish,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            color: AppColors.yellow.withValues(alpha: 0.95),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              slide.offer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingDishBubble extends StatelessWidget {
  const _FloatingDishBubble({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _LiveOffersBadge extends StatelessWidget {
  const _LiveOffersBadge({required this.pulse, required this.isMart});

  final Animation<double> pulse;
  final bool isMart;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        return Transform.scale(scale: 0.95 + pulse.value * 0.08, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isMart ? 'MART LIVE' : 'OFFERS LIVE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.index,
    required this.accent,
  });

  final int count;
  final int index;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(left: 4),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _MarqueeOffers extends StatelessWidget {
  const _MarqueeOffers({required this.slides, required this.anim});

  final List<PromoSlide> slides;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    final text = slides.map((s) => '${s.restaurant}: ${s.offer}').join('   •   ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 28,
        color: AppColors.yellow.withValues(alpha: 0.25),
        child: AnimatedBuilder(
          animation: anim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-anim.value * 200, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.bolt_rounded, size: 16, color: AppColors.ink),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
