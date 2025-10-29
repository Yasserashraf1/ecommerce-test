import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/pages/address/addresspage.dart' hide AddressModel;
import 'package:naseej/pages/payment/payment_methods_page.dart' hide PaymentMethodModel;
import 'package:naseej/pages/payment/add_payment_method_page.dart';
import 'package:naseej/models/cart_item.dart';
import 'package:naseej/models/address_model.dart' as models;
import 'package:naseej/models/payment_method_model.dart' as models;

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Use the prefixed models
  models.AddressModel _selectedAddress = models.AddressModel(
    id: '1',
    label: 'Home',
    fullName: 'John Doe',
    phone: '+20 123 456 7890',
    streetAddress: '123 Main Street, Apt 4B',
    city: 'Cairo',
    state: 'Cairo Governorate',
    zipCode: '11511',
    country: 'Egypt',
    isDefault: true,
  );

  models.PaymentMethodModel? _selectedPaymentMethod;
  DeliveryMethod _selectedDeliveryMethod = DeliveryMethod.delivery;
  PaymentType _selectedPaymentType = PaymentType.cashOnDelivery;

  List<models.PaymentMethodModel> _paymentMethods = [
    models.PaymentMethodModel(
      id: '1',
      cardType: 'Visa',
      cardHolderName: 'John Doe',
      cardNumber: '**** **** **** 4242',
      lastFourDigits: '4242',
      expiryDate: '12/25',
      cvv: '123',
      nickname: 'Personal Visa',
      isDefault: true,
    ),
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = _paymentMethods.firstWhere(
          (method) => method.isDefault,
      orElse: () => _paymentMethods.first,
    );
  }

  double get _calculatedShipping {
    return _selectedDeliveryMethod == DeliveryMethod.delivery ? widget.shipping : 0;
  }

  double get _calculatedTax {
    return widget.tax;
  }

  double get _calculatedTotal {
    return widget.subtotal + _calculatedShipping + _calculatedTax;
  }

  void _placeOrder() async {
    if (_selectedAddress.id.isEmpty) {
      _showErrorSnackBar('Please select a delivery address');
      return;
    }

    if (_selectedPaymentType == PaymentType.online && _selectedPaymentMethod == null) {
      _showErrorSnackBar('Please select a payment method');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual order placement API call
      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: AppColor.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      _showErrorSnackBar('Failed to place order. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Delivery Address',
                    onEdit: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddressPage()),
                      );
                      if (result == true) {
                        setState(() {});
                      }
                    },
                  ),
                  _buildAddressCard(isDark),
                  SizedBox(height: 24),
                  _buildSectionHeader(title: 'Delivery Method'),
                  _buildDeliveryMethodSection(isDark),
                  SizedBox(height: 24),
                  _buildSectionHeader(title: 'Payment Method'),
                  _buildPaymentMethodSection(isDark),
                  SizedBox(height: 24),
                  _buildSectionHeader(title: 'Order Items (${widget.cartItems.length})'),
                  _buildOrderItemsSection(isDark),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildOrderSummary(isDark),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow('Subtotal', widget.subtotal),
              _buildSummaryRow('Shipping', _calculatedShipping),
              _buildSummaryRow('Tax (8%)', _calculatedTax),
              Divider(height: 20, thickness: 2),
              _buildSummaryRow('Total', _calculatedTotal, isTotal: true),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Complete Order - \$${_calculatedTotal.toStringAsFixed(2)}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onEdit}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.primaryColor,
            ),
          ),
          Spacer(),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(50, 30),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_outlined, color: AppColor.primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedAddress.fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _selectedAddress.streetAddress,
                  style: TextStyle(color: AppColor.grey),
                ),
                Text(
                  '${_selectedAddress.city}, ${_selectedAddress.state} ${_selectedAddress.zipCode}',
                  style: TextStyle(color: AppColor.grey),
                ),
                Text(
                  _selectedAddress.phone,
                  style: TextStyle(color: AppColor.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: [
          // Delivery Option
          _buildDeliveryOption(
            isDark: isDark,
            method: DeliveryMethod.delivery,
            title: 'Home Delivery',
            subtitle: '2-3 business days',
            price: widget.shipping > 0 ? '\$${widget.shipping.toStringAsFixed(2)}' : 'Free',
            isSelected: _selectedDeliveryMethod == DeliveryMethod.delivery,
          ),
          SizedBox(height: 12),

          // Pickup Option
          _buildDeliveryOption(
            isDark: isDark,
            method: DeliveryMethod.pickup,
            title: 'Store Pickup',
            subtitle: 'Pick up from our nearest store',
            price: 'Free',
            isSelected: _selectedDeliveryMethod == DeliveryMethod.pickup,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({
    required bool isDark,
    required DeliveryMethod method,
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: AppColor.primaryColor)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColor.primaryColor : AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: [
          // Cash on Delivery Option
          _buildPaymentTypeOption(
            isDark: isDark,
            type: PaymentType.cashOnDelivery,
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive your order',
            isSelected: _selectedPaymentType == PaymentType.cashOnDelivery,
          ),
          SizedBox(height: 12),

          // Online Payment Option
          _buildPaymentTypeOption(
            isDark: isDark,
            type: PaymentType.online,
            title: 'Online Payment',
            subtitle: 'Pay securely with your card',
            isSelected: _selectedPaymentType == PaymentType.online,
          ),

          // Show saved payment methods if online payment is selected
          if (_selectedPaymentType == PaymentType.online) ...[
            SizedBox(height: 16),
            _buildSavedPaymentMethods(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentTypeOption({
    required bool isDark,
    required PaymentType type,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: AppColor.primaryColor)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPaymentMethods(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
          ),
        ),
        SizedBox(height: 8),

        // Saved Payment Methods
        if (_paymentMethods.isNotEmpty)
          Column(
            children: _paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod?.id == method.id;
              return _buildPaymentMethodCard(method, isSelected, isDark);
            }).toList(),
          ),

        // Add New Card Button
        SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddPaymentMethodPage()),
            );
            if (result == true) {
              // Refresh payment methods
              setState(() {});
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.primaryColor,
            side: BorderSide(color: AppColor.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.add, size: 18),
          label: Text('Add New Card'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(models.PaymentMethodModel method, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColor.primaryColor : AppColor.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: AppColor.primaryColor)
                  : null,
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCardColor(method.cardType),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method.cardType == 'Visa' ? 'VISA' :
                method.cardType == 'Mastercard' ? 'MC' : 'AMEX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.nickname ?? method.cardType,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColor.primaryColor,
                    ),
                  ),
                  Text(
                    method.cardNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderGray),
      ),
      child: Column(
        children: widget.cartItems.map((item) {
          return _buildOrderItem(item, isDark);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColor.backgroundcolor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColor.backgroundcolor2,
                    child: Icon(
                      Icons.image_outlined,
                      size: 20,
                      color: AppColor.grey,
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
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${item.size} • ${item.color}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 17 : 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: isTotal ? AppColor.primaryColor : AppColor.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 16),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 19 : 15,
              fontWeight: FontWeight.bold,
              color: isTotal ? AppColor.primaryColor : AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Color(0xFF1A1F71);
      case 'mastercard':
        return Color(0xFFEB001B);
      case 'amex':
        return Color(0xFF2E77BC);
      default:
        return AppColor.primaryColor;
    }
  }
}

// Enums for delivery and payment methods
enum DeliveryMethod { delivery, pickup }
enum PaymentType { cashOnDelivery, online }