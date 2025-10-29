class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  final String size;
  final String color;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.size,
    required this.color,
  });
}