import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/component/button.dart';
import 'package:naseej/pages/address/add_address_page.dart';
import 'package:naseej/pages/address/addresspage.dart';

class EditAddressPage extends StatefulWidget {
  final AddressModel address;

  const EditAddressPage({Key? key, required this.address}) : super(key: key);

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late String selectedLabel;

  // Controllers
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController streetController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipCodeController;
  late TextEditingController countryController;

  @override
  void initState() {
    super.initState();
    selectedLabel = widget.address.label;
    fullNameController = TextEditingController(text: widget.address.fullName);
    phoneController = TextEditingController(text: widget.address.phone);
    streetController = TextEditingController(text: widget.address.streetAddress);
    cityController = TextEditingController(text: widget.address.city);
    stateController = TextEditingController(text: widget.address.state);
    zipCodeController = TextEditingController(text: widget.address.zipCode);
    countryController = TextEditingController(text: widget.address.country);
  }

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

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make an API call here to update the address.
      // For this example, we'll just navigate back.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
        // You might want to pass the updated address back if needed
        Navigator.pop(context, true); // Pop and indicate success
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Label", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLabelChip('Home'),
                  const SizedBox(width: 10),
                  _buildLabelChip('Work'),
                  const SizedBox(width: 10),
                  _buildLabelChip('Other'),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: fullNameController,
                label: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: streetController,
                label: 'Street Address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: cityController,
                label: 'City',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: stateController,
                      label: 'State/Province',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: zipCodeController,
                      label: 'Zip Code',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your zip code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: countryController,
                label: 'Country',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Button(
                title: "Save Changes",
                onpressed: isLoading ? null : _updateAddress,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    bool isSelected = selectedLabel == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            selectedLabel = label;
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppColor.primaryColor.withOpacity(0.8),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColor.primaryColor : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColor.primaryColor),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}