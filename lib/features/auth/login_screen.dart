import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamat_timings/app/theme.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate login API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      
      final email = _emailController.text.trim();
      
      // Let's route based on role
      if (email.contains('admin')) {
        context.go('/super-admin/queue');
      } else {
        context.go('/admin/dashboard');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in successfully as: $email')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login', style: TextStyle(fontFamily: 'Amiri')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: IslamicPatternBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Masjid Management Console',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Authorized administrators and coordinators only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: const Icon(Icons.email, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter your email';
                    if (!value.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryGreen),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter your password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('Forgot Password?', style: TextStyle(color: AppTheme.primaryGreen)),
                    onPressed: () => context.push('/auth/forgot-password'),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('LOG IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
