import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';
import 'package:naseej/models/address_model.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String selectedLabel = 'Home';

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: 'Egypt');

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // TODO: Save to backend
        // await crud.postRequest(addAddressLink, {
        //   "userId": sharedPref.getString("user_id")!,
        //   "label": selectedLabel,
        //   "fullName": fullNameController.text.trim(),
        //   "phone": phoneController.text.trim(),
        //   "streetAddress": streetController.text.trim(),
        //   "city": cityController.text.trim(),
        //   "state": stateController.text.trim(),
        //   "zipCode": zipCodeController.text.trim(),
        //   "country": countryController.text.trim(),
        // });

        await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address added successfully!'),
            backgroundColor: AppColor.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add address'),
            backgroundColor: AppColor.warningColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Add New Address'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Label Selection
            Text(
              'Address Label',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildLabelChip('Home', Icons.home),
                SizedBox(width: 12),
                _buildLabelChip('Work', Icons.business),
                SizedBox(width: 12),
                _buildLabelChip('Other', Icons.location_on),
              ],
            ),
            SizedBox(height: 24),

            // Full Name
            _buildTextField(
              controller: fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Phone
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              hint: '+20 123 456 7890',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Street Address
            _buildTextField(
              controller: streetController,
              label: 'Street Address',
              hint: 'House number and street name',
              icon: Icons.home_outlined,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter street address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // City
            _buildTextField(
              controller: cityController,
              label: 'City',
              hint: 'Enter city',
              icon: Icons.location_city,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // State & Zip Code Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: stateController,
                    label: 'State/Province',
                    hint: 'State',
                    icon: Icons.map_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: zipCodeController,
                    label: 'Zip Code',
                    hint: '12345',
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Country
            _buildTextField(
              controller: countryController,
              label: 'Country',
              hint: 'Enter country',
              icon: Icons.public,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter country';
                }
                return null;
              },
            ),
            SizedBox(height: 32),

            // Save Button
            Button(
              title: 'Save Address',
              isLoading: isLoading,
              onpressed: _saveAddress,
              icon: Icons.save,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final bool isSelected = selectedLabel == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLabel = label;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [AppColor.primaryColor, AppColor.secondColor],
            )
                : null,
            color: isSelected ? null : (isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColor.borderGray,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColor.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColor.grey, fontSize: 13),
            prefixIcon: Icon(icon, size: 20, color: AppColor.primaryColor),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.warningColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.warningColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}