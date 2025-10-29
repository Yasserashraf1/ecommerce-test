import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/crud.dart';
import 'package:naseej/pages/address/add_address_page.dart';
import 'package:naseej/core/constant/links.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';
import 'edit_address_page.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  Crud crud = Crud();
  List<AddressModel> addresses = []; // Now this uses the model from models folder
  bool isLoading = true;
  int? selectedAddressIndex;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      // var response = await crud.postRequest(viewAddressesLink, {
      //   "userId": sharedPref.getString("user_id")!
      // });

      // Simulate data loading - Replace with actual API
      await Future.delayed(Duration(milliseconds: 500));

      // Demo data - Remove when API is ready
      addresses = [
        AddressModel(
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
        ),
        AddressModel(
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
        ),
      ];

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load addresses');
    }
  }

  Future<void> _deleteAddress(String id, int index) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.warningColor),
            SizedBox(width: 12),
            Text('Delete Address', style: TextStyle(color: AppColor.primaryColor)),
          ],
        ),
        content: Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.warningColor),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        addresses.removeAt(index);
      });

      // TODO: Delete from backend
      // await crud.postRequest(deleteAddressLink, {"addressId": id});

      _showSuccessSnackBar('Address deleted successfully');
    }
  }

  Future<void> _setDefaultAddress(int index) async {
    setState(() {
      for (var i = 0; i < addresses.length; i++) {
        addresses[i].isDefault = (i == index);
      }
    });

    // TODO: Update backend
    // await crud.postRequest(setDefaultAddressLink, {"addressId": addresses[index].id});

    _showSuccessSnackBar('Default address updated');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('My Addresses'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
          : addresses.isEmpty
          ? _buildEmptyState()
          : _buildAddressList(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressPage()),
          ).then((result) {
            if (result == true) {
              _loadAddresses();
            }
          });
        },
        backgroundColor: AppColor.primaryColor,
        icon: Icon(Icons.add_location_alt),
        label: Text('Add Address'),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.location_off_outlined,
                size: 80,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Addresses Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add your delivery addresses to\nmake checkout faster',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColor.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        return _buildAddressCard(addresses[index], index, isDark);
      },
    );
  }

  Widget _buildAddressCard(AddressModel address, int index, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2520) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault
              ? AppColor.primaryColor
              : (isDark ? AppColor.earthBrown.withOpacity(0.2) : AppColor.borderGray),
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Label Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getLabelColors(address.label),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getLabelIcon(address.label), size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        address.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),

                // Default Badge
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.successColor),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        color: AppColor.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                Spacer(),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColor.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAddressPage(address: address),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadAddresses();
                        }
                      });
                    } else if (value == 'default') {
                      _setDefaultAddress(index);
                    } else if (value == 'delete') {
                      _deleteAddress(address.id, index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: AppColor.primaryColor),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: AppColor.successColor),
                            SizedBox(width: 12),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColor.warningColor),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 12),

            // Full Name
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: AppColor.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.fullName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Phone
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 18, color: AppColor.grey),
                SizedBox(width: 8),
                Text(
                  address.phone,
                  style: TextStyle(fontSize: 14, color: AppColor.grey),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 18, color: AppColor.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${address.streetAddress}\n${address.city}, ${address.state} ${address.zipCode}\n${address.country}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColor.grey,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getLabelColors(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return [AppColor.primaryColor, AppColor.secondColor];
      case 'work':
        return [AppColor.goldAccent, AppColor.earthBrown];
      case 'other':
        return [AppColor.earthBrown, AppColor.bronzeAccent];
      default:
        return [AppColor.primaryColor, AppColor.secondColor];
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }
}

// Address Model
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
  bool isDefault;

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
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      label: json['label'] ?? 'Other',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}