import 'menu_items.dart';

class Restaurant {
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final int price;
  final String deliveryTime;
  final bool isAvailable;
  final String imageUrl;
  bool isFavorite;
  final String openingHours;
  final String deliveryType;
  final List<MenuItem> menuItems; // Add menu items

  Restaurant({
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.deliveryTime,
    required this.isAvailable,
    required this.imageUrl,
    this.isFavorite = false,
    required this.openingHours,
    required this.deliveryType,
    required this.menuItems,
  });
}
