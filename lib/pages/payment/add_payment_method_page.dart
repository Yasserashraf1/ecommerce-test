import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/main.dart';
import 'package:naseej/l10n/generated/app_localizations.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String selectedCardType = 'Visa';
  bool isDefaultPayment = false;

  // Controllers
  final TextEditingController cardHolderNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  @override
  void dispose() {
    cardHolderNameController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String input) {
    // Remove all non-digits
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');

    // Format as XXXX XXXX XXXX XXXX
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digits[i];
    }

    return formatted;
  }

  String _formatExpiryDate(String input) {
    // Remove all non-digits
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length >= 2) {
      return '${digits.substring(0, 2)}/${digits.length > 2 ? digits.substring(2, 4) : ''}';
    }
    return digits;
  }

  Future<void> _savePaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // TODO: Save to backend
        // await crud.postRequest(addPaymentMethodLink, {
        //   "userId": sharedPref.getString("user_id")!,
        //   "cardType": selectedCardType,
        //   "cardHolderName": cardHolderNameController.text.trim(),
        //   "cardNumber": cardNumberController.text.replaceAll(' ', ''),
        //   "expiryDate": expiryDateController.text.trim(),
        //   "cvv": cvvController.text.trim(),
        //   "nickname": nicknameController.text.trim().isEmpty ? null : nicknameController.text.trim(),
        //   "isDefault": isDefaultPayment,
        // });

        await Future.delayed(Duration(milliseconds: 500)); // Simulate API call

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment method added successfully!'),
            backgroundColor: AppColor.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add payment method'),
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

  Widget _buildCardTypeChip(String type) {
    final bool isSelected = selectedCardType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCardType = type;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
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
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: _getCardColor(type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    type == 'Visa' ? 'VISA' : type == 'Mastercard' ? 'MC' : 'AMEX',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                type,
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

  Color _getCardColor(String type) {
    switch (type) {
      case 'Visa':
        return Color(0xFF1A1F71);
      case 'Mastercard':
        return Color(0xFFEB001B);
      case 'Amex':
        return Color(0xFF2E77BC);
      default:
        return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1614) : AppColor.backgroundcolor,
      appBar: AppBar(
        title: Text('Add Payment Method'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            // Card Type Selection
            Text(
              'Card Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildCardTypeChip('Visa'),
                SizedBox(width: 12),
                _buildCardTypeChip('Mastercard'),
                SizedBox(width: 12),
                _buildCardTypeChip('Amex'),
              ],
            ),
            SizedBox(height: 24),

            // Card Nickname (Optional)
            _buildTextField(
              controller: nicknameController,
              label: 'Card Nickname (Optional)',
              hint: 'e.g., Personal Visa, Business Card',
              icon: Icons.credit_card_outlined,
              validator: null, // Optional field
            ),
            SizedBox(height: 16),

            // Cardholder Name
            _buildTextField(
              controller: cardHolderNameController,
              label: 'Cardholder Name',
              hint: 'Enter name as shown on card',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter cardholder name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Card Number
            _buildTextField(
              controller: cardNumberController,
              label: 'Card Number',
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
              ],
              onChanged: (value) {
                // Format the card number as user types
                final formatted = _formatCardNumber(value);
                if (formatted != value) {
                  cardNumberController.value = cardNumberController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter card number';
                }
                // Basic card number validation (16 digits for Visa/MC, 15 for Amex)
                final digits = value.replaceAll(' ', '');
                if (selectedCardType == 'Amex') {
                  if (digits.length != 15) {
                    return 'American Express cards have 15 digits';
                  }
                } else {
                  if (digits.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Expiry Date & CVV Row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: expiryDateController,
                    label: 'Expiry Date',
                    hint: 'MM/YY',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: (value) {
                      // Format the expiry date as user types
                      final formatted = _formatExpiryDate(value);
                      if (formatted != value) {
                        expiryDateController.value = expiryDateController.value.copyWith(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
                        return 'Invalid format (MM/YY)';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: cvvController,
                    label: 'CVV',
                    hint: selectedCardType == 'Amex' ? '1234' : '123',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(selectedCardType == 'Amex' ? 4 : 3),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (selectedCardType == 'Amex') {
                        if (value.length != 4) {
                          return '4 digits required';
                        }
                      } else {
                        if (value.length != 3) {
                          return '3 digits required';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Set as Default Payment Method
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2C2520) : AppColor.backgroundcolor2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: AppColor.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set as default payment method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColor.primaryColor,
                      ),
                    ),
                  ),
                  Switch(
                    value: isDefaultPayment,
                    onChanged: (value) {
                      setState(() {
                        isDefaultPayment = value;
                      });
                    },
                    activeColor: AppColor.primaryColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Security Note
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2C2520).withOpacity(0.5) : AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppColor.successColor,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment information is secured with encryption and never stored on our servers.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColor.goldAccent : AppColor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Save Button
            Button(
              title: 'Save Payment Method',
              isLoading: isLoading,
              onpressed: _savePaymentMethod,
              icon: Icons.save,
            ),
            SizedBox(height: 20),
          ],
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
    Function(String)? onChanged,
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
          onChanged: onChanged,
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