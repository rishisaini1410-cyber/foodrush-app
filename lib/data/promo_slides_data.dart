import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/promo_slide.dart';

const foodPromoSlides = [
  PromoSlide(
    restaurant: 'Spice Route Kitchen',
    dish: 'Paneer Butter Masala',
    offer: '40% OFF • Top rated',
    category: 'Top Offers',
    gradientStart: Color(0xFF168557),
    gradientEnd: Color(0xFF0D5C3A),
    dishIcon: Icons.ramen_dining_rounded,
    badge: 'TOP',
  ),
  PromoSlide(
    restaurant: 'Brew & Bean Cafe',
    dish: 'Caramel Latte + Croissant',
    offer: 'Buy 1 Get 1 • Coffee rush',
    category: 'Coffee',
    gradientStart: Color(0xFF6F4E37),
    gradientEnd: Color(0xFF3D2817),
    dishIcon: Icons.coffee_rounded,
    badge: 'NEW',
  ),
  PromoSlide(
    restaurant: 'Tandoori Nights',
    dish: 'Chicken Biryani Family Pack',
    offer: '₹99 delivery • 25 min',
    category: 'Fast Food',
    gradientStart: Color(0xFFC83A25),
    gradientEnd: Color(0xFF8B1E0F),
    dishIcon: Icons.lunch_dining_rounded,
    badge: 'HOT',
  ),
  PromoSlide(
    restaurant: 'The Grand Table',
    dish: 'Fine Dine Thali for 2',
    offer: 'Flat ₹200 off dining',
    category: 'Dining',
    gradientStart: Color(0xFF5B3FA6),
    gradientEnd: Color(0xFF2E1F5C),
    dishIcon: Icons.restaurant_menu_rounded,
    badge: 'DINE',
  ),
  PromoSlide(
    restaurant: 'Street Wok',
    dish: 'Hakka Noodles Combo',
    offer: 'Free dessert above ₹399',
    category: 'Fast Food',
    gradientStart: Color(0xFFE84932),
    gradientEnd: Color(0xFFF5B335),
    dishIcon: Icons.rice_bowl_rounded,
    badge: 'COMBO',
  ),
  PromoSlide(
    restaurant: 'Dosa Corner',
    dish: 'Masala Dosa + Filter Coffee',
    offer: '30% OFF • South specials',
    category: 'Top Offers',
    gradientStart: Color(0xFF168557),
    gradientEnd: Color(0xFFF5B335),
    dishIcon: Icons.breakfast_dining_rounded,
    badge: 'VEG',
  ),
];

const martPromoSlides = [
  PromoSlide(
    restaurant: 'RushMart Fresh',
    dish: 'Farm Fresh Vegetables',
    offer: 'Delivery in 10 mins',
    category: 'Vegetables',
    gradientStart: Color(0xFF0E7A4A),
    gradientEnd: Color(0xFF053D25),
    dishIcon: Icons.eco_rounded,
    badge: '10 MIN',
  ),
  PromoSlide(
    restaurant: 'RushMart Dairy',
    dish: 'Amul Milk + Curd Pack',
    offer: 'Up to 25% OFF',
    category: 'Dairy',
    gradientStart: Color(0xFF2563EB),
    gradientEnd: Color(0xFF1E3A8A),
    dishIcon: Icons.local_drink_rounded,
    badge: 'DEAL',
  ),
  PromoSlide(
    restaurant: 'RushMart Snacks',
    dish: 'Lay\'s + Kurkure Mega Pack',
    offer: 'Buy 2 Get 1 Free',
    category: 'Snacks',
    gradientStart: Color(0xFFEA580C),
    gradientEnd: Color(0xFF9A3412),
    dishIcon: Icons.cookie_rounded,
    badge: 'B2G1',
  ),
  PromoSlide(
    restaurant: 'RushMart Home',
    dish: 'Surf Excel + Harpic Combo',
    offer: 'Instamart se better prices',
    category: 'Home Care',
    gradientStart: Color(0xFF7C3AED),
    gradientEnd: Color(0xFF4C1D95),
    dishIcon: Icons.cleaning_services_rounded,
    badge: 'SAVE',
  ),
];

const foodOfferCategories = [
  'Top Offers',
  'Dining',
  'Coffee',
  'Fast Food',
];

const martOfferCategories = [
  'Vegetables',
  'Dairy',
  'Snacks',
  'Home Care',
];

Color categoryColor(String category) {
  switch (category) {
    case 'Dining':
      return const Color(0xFF5B3FA6);
    case 'Coffee':
      return const Color(0xFF6F4E37);
    case 'Fast Food':
      return AppColors.red;
    case 'Top Offers':
      return AppColors.vegAccent;
    case 'Vegetables':
      return const Color(0xFF0E7A4A);
    case 'Dairy':
      return const Color(0xFF2563EB);
    case 'Snacks':
      return const Color(0xFFEA580C);
    case 'Home Care':
      return const Color(0xFF7C3AED);
    default:
      return AppColors.yellow;
  }
}
