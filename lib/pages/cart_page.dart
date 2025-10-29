import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import '../l10n/generated/app_localizations.dart';
import 'checkout_page.dart';
import 'package:naseej/models/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [
    CartItem(
      id: '1',
      name: 'Traditional Burgundy',
      price: 299.99,
      quantity: 1,
      imageUrl: 'https://via.placeholder.com/100',
      size: '6x9 ft',
      color: 'Burgundy',
    ),
    CartItem(
      id: '2',
      name: 'Modern Abstract',
      price: 449.99,
      quantity: 2,
      imageUrl: 'https://via.placeholder.com/100',
      size: '8x10 ft',
      color: 'Multi',
    ),
    CartItem(
      id: '3',
      name: 'Vintage Persian',
      price: 599.99,
      quantity: 1,
      imageUrl: 'https://via.placeholder.com/100',
      size: '9x12 ft',
      color: 'Gold',
    ),
  ];

  double get subtotal =>
      cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get shipping => subtotal > 500 ? 0 : 49.99;
  double get tax => subtotal * 0.08;
  double get total => subtotal + shipping + tax;

  void _updateQuantity(String id, int delta) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        final newQuantity = cartItems[index].quantity + delta;
        if (newQuantity > 0) {
          cartItems[index].quantity = newQuantity;
        } else {
          _removeItem(id);
        }
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      cartItems.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: _showClearCartDialog,
            ),
        ],
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(isDark),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add beautiful carpets to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to home - will be handled by bottom nav
              },
              icon: Icon(Icons.shopping_bag),
              label: Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(bool isDark) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(cartItems[index], isDark);
            },
          ),
        ),

        // Summary Card - FIXED OVERFLOW
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF2C2520) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Changed to min
                children: [
                  // Minimal Summary - Only key info
                  _buildMinimalSummaryRow('Subtotal', subtotal),
                  if (shipping > 0)
                    _buildMinimalSummaryRow('Shipping', shipping),
                  _buildMinimalSummaryRow('Tax', tax),

                  Divider(height: 16, thickness: 1),

                  // Total - Emphasized
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Checkout Button - FIXED HEIGHT
                  SizedBox(
                    width: double.infinity,
                    height: 56, // Increased height
                    child: ElevatedButton(
                      onPressed: _navigateToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward, size: 20),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Continue to Checkout',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Free shipping hint - only if applicable
                  if (shipping > 0) ...[
                    SizedBox(height: 8),
                    Text(
                      'Add \$${(500 - subtotal).toStringAsFixed(2)} more for free shipping!',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.goldAccent,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (subtotal >= 500) ...[
                    SizedBox(height: 8),
                    Text(
                      '🎉 You got free shipping!',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColor.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColor.backgroundcolor2,
                      child: Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: AppColor.grey,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColor.backgroundcolor2,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item.size} • ${item.color}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () => _updateQuantity(item.id, -1),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () => _updateQuantity(item.id, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColor.warningColor, size: 20),
              onPressed: () => _removeItem(item.id),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildMinimalSummaryRow(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.grey,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear Cart?', style: TextStyle(color: AppColor.primaryColor)),
        content: Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cart cleared'),
                  backgroundColor: AppColor.successColor,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.warningColor,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: cartItems,
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          total: total,
        ),
      ),
    );
  }
}