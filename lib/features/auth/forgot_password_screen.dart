import 'package:flutter/material.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Link Sent'),
        content: Text('A password reset link has been dispatched to: ${_emailController.text}'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // back to login
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Password', style: theme.textTheme.titleLarge),
      ),
      body: IslamicPatternBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.lock_reset, size: 80, color: colorScheme.primary.withValues(alpha: 0.85)),
              const SizedBox(height: 24),
              Text(
                'Forgot Your Password?',
                style: theme.textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your registered administrator email. We will send you a secure link to reset your credentials.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetLink,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('SEND RESET LINK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
