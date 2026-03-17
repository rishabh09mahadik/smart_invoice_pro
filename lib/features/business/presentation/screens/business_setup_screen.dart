import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';
import 'package:smart_invoice_pro/features/business/presentation/providers/business_provider.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  String _selectedCurrency = 'USD';
  bool _isInitialized = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessDetailsAsync = ref.watch(businessDetailsProvider);

    // Load initial data
    businessDetailsAsync.whenData((details) {
      if (!_isInitialized) {
        _businessNameController.text = details['name'] ?? '';
        _addressController.text = details['address'] ?? '';
        _phoneController.text = details['phone'] ?? '';
        _emailController.text = details['email'] ?? '';
        _gstController.text = details['gst'] ?? '';
        _selectedCurrency = details['currency']!.isNotEmpty ? details['currency']! : 'USD';
        _isInitialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
      ),
      body: SafeArea(
        child: businessDetailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Setup Your Business',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your business details to get started.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.business,
                            size: 48,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: () {
                                // TODO: Pick Image
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Business Name',
                    hint: 'e.g. Acme Corp',
                    controller: _businessNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter business name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Address',
                    hint: 'Business Address',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Phone',
                    hint: 'Business Phone',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Business Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'GST / Tax Number (Optional)',
                    hint: 'e.g. GSTIN123456',
                    controller: _gstController,
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                      DropdownMenuItem(value: 'INR', child: Text('INR - Indian Rupee')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Save Details',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await ref.read(businessNotifierProvider.notifier).saveDetails(
                          name: _businessNameController.text,
                          address: _addressController.text,
                          phone: _phoneController.text,
                          email: _emailController.text,
                          gst: _gstController.text,
                          currency: _selectedCurrency,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Business details saved!')),
                          );
                          context.pop();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
