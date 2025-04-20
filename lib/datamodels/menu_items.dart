class MenuItem {
  final String name;
  final String description;
  final int price;
  final bool isAvailable;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.imageUrl,
  });
}