import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/core/widgets/common_widgets.dart';
import 'package:smart_invoice_pro/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user['name'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                // Save changes
                // Note: You'll need to implement updateProfile in AuthProvider/Repository
                // For now, we'll just toggle mode
                setState(() => _isEditing = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated (Simulation)')),
                );
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                user['email'] != null && (user['email'] as String).isNotEmpty
                    ? (user['email'] as String)[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              label: 'Display Name',
              controller: _nameController,
              enabled: _isEditing,
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email Address',
              controller: TextEditingController(text: user['email']),
              enabled: false,
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              PrimaryButton(
                text: 'Save Changes',
                onPressed: () {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated (Simulation)')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
