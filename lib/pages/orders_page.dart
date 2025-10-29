import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  Crud crud = Crud();
  List<OrderModel> orders = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(Duration(milliseconds: 800));

      // Create reusable objects
      final defaultAddress = AddressModel(
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

      final workAddress = AddressModel(
        id: '2',
        label: 'Work',
        fullName: 'John Doe',
        phone: '+20 123 456 7890',
        streetAddress: '456 Business Ave, Floor 5',
        city: 'Giza',
        state: 'Giza Governorate',
        zipCode: '12345',
        country: 'Egypt',
        isDefault: false,
      );

      final visaPayment = PaymentMethodModel(
        id: '1',
        cardType: 'Visa',
        cardHolderName: 'John Doe',
        cardNumber: '**** **** **** 4242',
        lastFourDigits: '4242',
        expiryDate: '12/25',
        cvv: '123',
        nickname: 'Personal Visa',
        isDefault: true,
      );

      final mastercardPayment = PaymentMethodModel(
        id: '2',
        cardType: 'Mastercard',
        cardHolderName: 'John Doe',
        cardNumber: '**** **** **** 5555',
        lastFourDigits: '5555',
        expiryDate: '08/24',
        cvv: '456',
        nickname: 'Business Card',
        isDefault: false,
      );

      // Demo data with proper paymentMethod parameters
      orders = [
        OrderModel(
          id: 'ORD-001',
          orderDate: DateTime.now().subtract(Duration(days: 2)),
          deliveryDate: DateTime.now().add(Duration(days: 5)),
          items: [
            OrderItem(
              id: '1',
              name: 'Persian Silk Carpet',
              image: 'assets/images/rug1.jpg',
              quantity: 1,
              price: 2500.00,
              attributes: {'Size': '6x9 ft', 'Color': 'Red/Gold'},
            ),
            OrderItem(
              id: '2',
              name: 'Egyptian Wool Runner',
              image: 'assets/images/rug1.jpg',
              quantity: 2,
              price: 450.00,
              attributes: {'Size': '3x10 ft', 'Color': 'Beige'},
            ),
          ],
          totalAmount: 3400.00,
          status: OrderStatus.onTheWay,
          shippingAddress: defaultAddress,
          paymentMethod: visaPayment,
          trackingNumber: 'TRK789456123',
          estimatedDelivery: DateTime.now().add(Duration(days: 5)),
        ),
        OrderModel(
          id: 'ORD-002',
          orderDate: DateTime.now().subtract(Duration(days: 7)),
          deliveryDate: DateTime.now().subtract(Duration(days: 1)),
          items: [
            OrderItem(
              id: '3',
              name: 'Moroccan Berber Carpet',
              image: 'assets/images/rug1.jpg',
              quantity: 1,
              price: 1800.00,
              attributes: {'Size': '8x10 ft', 'Color': 'Multicolor'},
            ),
          ],
          totalAmount: 1800.00,
          status: OrderStatus.delivered,
          shippingAddress: workAddress,
          paymentMethod: mastercardPayment,
          trackingNumber: 'TRK123456789',
          estimatedDelivery: DateTime.now().subtract(Duration(days: 1)),
        ),
        OrderModel(
          id: 'ORD-003',
          orderDate: DateTime.now().subtract(Duration(days: 1)),
          deliveryDate: DateTime.now().add(Duration(days: 3)),
          items: [
            OrderItem(
              id: '4',
              name: 'Turkish Kilim',
              image: 'assets/images/rug1.jpg',
              quantity: 1,
              price: 1200.00,
              attributes: {'Size': '5x8 ft', 'Color': 'Blue/White'},
            ),
          ],
          totalAmount: 1200.00,
          status: OrderStatus.preparing,
          shippingAddress: defaultAddress,
          paymentMethod: visaPayment,
          trackingNumber: 'TRK456123789',
          estimatedDelivery: DateTime.now().add(Duration(days: 3)),
        ),
        OrderModel(
          id: 'ORD-004',
          orderDate: DateTime.now().subtract(Duration(days: 10)),
          deliveryDate: DateTime.now().subtract(Duration(days: 3)),
          items: [
            OrderItem(
              id: '5',
              name: 'Persian Area Rug',
              image: 'assets/images/rug1.jpg',
              quantity: 1,
              price: 3200.00,
              attributes: {'Size': '9x12 ft', 'Color': 'Cream/Burgundy'},
            ),
          ],
          totalAmount: 3200.00,
          status: OrderStatus.received,
          shippingAddress: defaultAddress,
          paymentMethod: visaPayment,
          isStorePickup: true,
          storeLocation: 'Naseej Main Store - Downtown Cairo',
        ),
        OrderModel(
          id: 'ORD-005',
          orderDate: DateTime.now().subtract(Duration(days: 5)),
          deliveryDate: DateTime.now().add(Duration(days: 2)),
          items: [
            OrderItem(
              id: '6',
              name: 'Egyptian Cotton Carpet',
              image: 'assets/images/rug1.jpg',
              quantity: 1,
              price: 950.00,
              attributes: {'Size': '4x6 ft', 'Color': 'Green'},
            ),
          ],
          totalAmount: 950.00,
          status: OrderStatus.cancelled,
          shippingAddress: defaultAddress,
          paymentMethod: visaPayment,
          cancellationReason: 'Changed my mind',
        ),
      ];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load orders');
    }
  }

  List<OrderModel> get activeOrders {
    return orders.where((order) =>
    order.status != OrderStatus.delivered &&
        order.status != OrderStatus.received &&
        order.status != OrderStatus.cancelled
    ).toList();
  }

  List<OrderModel> get completedOrders {
    return orders.where((order) =>
    order.status == OrderStatus.delivered ||
        order.status == OrderStatus.received
    ).toList();
  }

  List<OrderModel> get cancelledOrders {
    return orders.where((order) => order.status == OrderStatus.cancelled).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.warningColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  Future<void> _cancelOrder(OrderModel order) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text('Cancel Order', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Keep Order', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.warningColor),
            child: Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Update order status via API
      setState(() {
        order.status = OrderStatus.cancelled;
      });
      _showSuccessSnackBar('Order cancelled successfully');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.successColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }

  void _trackOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderTrackingDialog(order: order),
    );
  }

  void _reorder(OrderModel order) {
    // TODO: Implement reorder functionality
    _showSuccessSnackBar('Items added to cart for reorder');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 16.0),
          labelColor: Colors.white, // Active tab text color
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Inactive tab text color
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: 'Active (${activeOrders.length})'),
            Tab(text: 'Completed (${completedOrders.length})'),
            Tab(text: 'Cancelled (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(activeOrders, isDark),
          _buildOrdersList(completedOrders, isDark),
          _buildOrdersList(cancelledOrders, isDark),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> ordersToShow, bool isDark) {
    if (ordersToShow.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      backgroundColor: AppColor.primaryColor,
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: ordersToShow.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(ordersToShow[index], isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
                Icons.shopping_bag_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your orders will appear here once you make a purchase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to products page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Start Shopping', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ordered on ${_formatDate(order.orderDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.grey,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                _buildStatusChip(order.status),
              ],
            ),
          ),

          // Items
          ...order.items.map((item) => _buildOrderItem(item, isDark)).toList(),

          Divider(height: 1),

          // Footer
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      if (order.trackingNumber != null)
                        Text(
                          'Tracking: ${order.trackingNumber!}',
                          style: TextStyle(fontSize: 12, color: AppColor.grey),
                        ),
                      if (order.isStorePickup)
                        Text(
                          'Store Pickup',
                          style: TextStyle(fontSize: 12, color: AppColor.goldAccent),
                        ),
                    ],
                  ),
                ),
                _buildActionButtons(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColor.backgroundcolor2,
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColor.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                ...item.attributes.entries.map((attr) => Text(
                  '${attr.key}: ${attr.value}',
                  style: TextStyle(fontSize: 12, color: AppColor.grey),
                )).toList(),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: AppColor.grey),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.goldAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 14, color: statusInfo.color),
          SizedBox(width: 6),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    return Row(
      children: [
        if (order.status == OrderStatus.onTheWay || order.status == OrderStatus.preparing)
          IconButton(
            onPressed: () => _trackOrder(order),
            icon: Icon(Icons.track_changes_outlined, size: 20),
            color: AppColor.primaryColor,
            tooltip: 'Track Order',
          ),
        if (order.status == OrderStatus.preparing)
          IconButton(
            onPressed: () => _cancelOrder(order),
            icon: Icon(Icons.cancel_outlined, size: 20),
            color: AppColor.warningColor,
            tooltip: 'Cancel Order',
          ),
        if (order.status == OrderStatus.delivered || order.status == OrderStatus.received)
          IconButton(
            onPressed: () => _reorder(order),
            icon: Icon(Icons.replay_outlined, size: 20),
            color: AppColor.successColor,
            tooltip: 'Reorder',
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return StatusInfo(
          text: 'Preparing',
          color: AppColor.goldAccent,
          icon: Icons.schedule_outlined,
        );
      case OrderStatus.onTheWay:
        return StatusInfo(
          text: 'On the Way',
          color: AppColor.primaryColor,
          icon: Icons.local_shipping_outlined,
        );
      case OrderStatus.delivered:
        return StatusInfo(
          text: 'Delivered',
          color: AppColor.successColor,
          icon: Icons.check_circle_outline,
        );
      case OrderStatus.received:
        return StatusInfo(
          text: 'Received',
          color: AppColor.successColor,
          icon: Icons.storefront_outlined,
        );
      case OrderStatus.cancelled:
        return StatusInfo(
          text: 'Cancelled',
          color: AppColor.warningColor,
          icon: Icons.cancel_outlined,
        );
    }
  }
}

// Order Tracking Dialog
class OrderTrackingDialog extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingDialog({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? Color(0xFF2C2520) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes_outlined, color: AppColor.primaryColor),
                SizedBox(width: 12),
                Text(
                  'Order Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryColor,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Tracking Number: ${order.trackingNumber!}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            _buildTrackingStepper(order.status),
            SizedBox(height: 20),
            if (order.estimatedDelivery != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColor.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Estimated Delivery: ${_formatDate(order.estimatedDelivery!)}',
                      style: TextStyle(color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStepper(OrderStatus currentStatus) {
    final steps = [
      _TrackingStep('Order Placed', OrderStatus.preparing, Icons.shopping_bag_outlined),
      _TrackingStep('Preparing', OrderStatus.preparing, Icons.schedule_outlined),
      _TrackingStep('On the Way', OrderStatus.onTheWay, Icons.local_shipping_outlined),
      _TrackingStep('Delivered', OrderStatus.delivered, Icons.check_circle_outlined),
    ];

    int currentStepIndex = steps.indexWhere((step) => step.status == currentStatus);
    if (currentStepIndex == -1) currentStepIndex = steps.length - 1;

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = index <= currentStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColor.primaryColor : AppColor.grey.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(step.icon, size: 16, color: Colors.white),
            ),
            SizedBox(width: 12),
            // Step Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColor.primaryColor : AppColor.grey,
                    ),
                  ),
                  if (!isLast) SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TrackingStep {
  final String title;
  final OrderStatus status;
  final IconData icon;

  _TrackingStep(this.title, this.status, this.icon);
}

// Models and Enums
enum OrderStatus {
  preparing,
  onTheWay,
  delivered,
  received,
  cancelled,
}

class OrderModel {
  final String id;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final List<OrderItem> items;
  final double totalAmount;
  OrderStatus status;
  final AddressModel shippingAddress;
  final PaymentMethodModel paymentMethod;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final bool isStorePickup;
  final String? storeLocation;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.orderDate,
    required this.deliveryDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber,
    this.estimatedDelivery,
    this.isStorePickup = false,
    this.storeLocation,
    this.cancellationReason,
  });
}

class OrderItem {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final double price;
  final Map<String, String> attributes;

  OrderItem({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.attributes,
  });
}

class StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  StatusInfo({required this.text, required this.color, required this.icon});
}

class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
  });
}

class PaymentMethodModel {
  final String id;
  final String cardType;
  final String cardHolderName;
  final String cardNumber;
  final String lastFourDigits;
  final String expiryDate;
  final String cvv;
  final String? nickname;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.cardType,
    required this.cardHolderName,
    required this.cardNumber,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cvv,
    this.nickname,
    required this.isDefault,
  });
}

// import 'package:flutter/material.dart';
// import 'package:naseej/core/constant/color.dart';
// import '../l10n/generated/app_localizations.dart';
//
// class OrdersPage extends StatefulWidget {
//   const OrdersPage({Key? key}) : super(key: key);
//
//   @override
//   State<OrdersPage> createState() => _OrdersPageState();
// }
//
// class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
//       appBar: AppBar(
//         title: Text('My Orders'),
//         backgroundColor: AppColor.primaryColor,
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.white,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white.withOpacity(0.6),
//           tabs: [
//             Tab(
//               icon: Icon(Icons.pending_actions),
//               text: 'Active',
//             ),
//             Tab(
//               icon: Icon(Icons.history),
//               text: 'History',
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildActiveOrders(isDark),
//           _buildOrderHistory(isDark),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActiveOrders(bool isDark) {
//     // Sample data - replace with actual API call
//     List<Map<String, dynamic>> activeOrders = [
//       {
//         'id': '#12345',
//         'date': '2025-01-15',
//         'status': 'Processing',
//         'total': '\$599.99',
//         'items': 2,
//       },
//       {
//         'id': '#12346',
//         'date': '2025-01-16',
//         'status': 'Shipped',
//         'total': '\$299.99',
//         'items': 1,
//       },
//     ];
//
//     if (activeOrders.isEmpty) {
//       return _buildEmptyState('No active orders', 'Your active orders will appear here', isDark);
//     }
//
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: activeOrders.length,
//       itemBuilder: (context, index) {
//         return _buildOrderCard(activeOrders[index], isDark, true);
//       },
//     );
//   }
//
//   Widget _buildOrderHistory(bool isDark) {
//     // Sample data - replace with actual API call
//     List<Map<String, dynamic>> orderHistory = [
//       {
//         'id': '#12340',
//         'date': '2025-01-10',
//         'status': 'Delivered',
//         'total': '\$449.99',
//         'items': 1,
//       },
//     ];
//
//     if (orderHistory.isEmpty) {
//       return _buildEmptyState('No order history', 'Your completed orders will appear here', isDark);
//     }
//
//     return ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: orderHistory.length,
//       itemBuilder: (context, index) {
//         return _buildOrderCard(orderHistory[index], isDark, false);
//       },
//     );
//   }
//
//   Widget _buildOrderCard(Map<String, dynamic> order, bool isDark, bool isActive) {
//     Color statusColor;
//     switch (order['status']) {
//       case 'Processing':
//         statusColor = Colors.orange;
//         break;
//       case 'Shipped':
//         statusColor = Colors.blue;
//         break;
//       case 'Delivered':
//         statusColor = AppColor.successColor;
//         break;
//       default:
//         statusColor = AppColor.grey;
//     }
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? Color(0xFF2C2520) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColor.primaryColor.withOpacity(0.08),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 order['id'],
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.primaryColor,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   order['status'],
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(Icons.calendar_today, size: 16, color: AppColor.grey),
//               SizedBox(width: 8),
//               Text(
//                 order['date'],
//                 style: TextStyle(color: AppColor.grey),
//               ),
//               SizedBox(width: 24),
//               Icon(Icons.shopping_bag, size: 16, color: AppColor.grey),
//               SizedBox(width: 8),
//               Text(
//                 '${order['items']} items',
//                 style: TextStyle(color: AppColor.grey),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Divider(),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 order['total'],
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColor.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () {
//                     // View details
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: AppColor.primaryColor),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text('View Details'),
//                 ),
//               ),
//               if (isActive) ...[
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Track order
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColor.primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text('Track Order'),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(String title, String subtitle, bool isDark) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: EdgeInsets.all(40),
//             decoration: BoxDecoration(
//               color: AppColor.primaryColor.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.shopping_bag_outlined,
//               size: 80,
//               color: AppColor.primaryColor,
//             ),
//           ),
//           SizedBox(height: 24),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: AppColor.primaryColor,
//             ),
//           ),
//           SizedBox(height: 12),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColor.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }