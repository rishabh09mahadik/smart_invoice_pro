import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';
import 'package:smart_invoice_pro/features/customers/domain/models/customer_model.dart';
import 'package:smart_invoice_pro/features/customers/presentation/providers/customer_provider.dart';
import 'package:smart_invoice_pro/core/services/notification_service.dart';
import 'package:smart_invoice_pro/core/utils/validators.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const AddEditCustomerScreen({super.key, this.customerId});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(customerRepositoryProvider);
      final customer = await repository.read(int.parse(widget.customerId!));
      if (customer != null) {
        _nameController.text = customer.name;
        _phoneController.text = customer.phone;
        _emailController.text = customer.email;
        _addressController.text = customer.address;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading customer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final customer = Customer(
          id: widget.customerId != null ? int.parse(widget.customerId!) : null,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
        );

        if (widget.customerId != null) {
          await ref.read(customerListProvider.notifier).updateCustomer(customer);
          NotificationService().showNotification(
            title: 'Customer Updated',
            body: '${customer.name} has been updated successfully! 👤',
          );
        } else {
          await ref.read(customerListProvider.notifier).addCustomer(customer);
          NotificationService().showNotification(
            title: 'Customer Added',
            body: '${customer.name} has been added successfully! 👤',
          );
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving customer: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customerId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: 'Customer Name',
                        hint: 'Enter customer name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (value) => Validators.validateRequired(value, 'Customer Name'),
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: 'Address',
                        hint: 'Enter billing address',
                        controller: _addressController,
                        maxLines: 3,
                        prefixIcon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        text: isEditing ? 'Update Customer' : 'Save Customer',
                        onPressed: _saveCustomer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
