import 'package:flutter/material.dart';
import 'package:jamat_timings/widgets/islamic_pattern_bg.dart';

class MasjidRequestScreen extends StatefulWidget {
  const MasjidRequestScreen({super.key});

  @override
  State<MasjidRequestScreen> createState() => _MasjidRequestScreenState();
}

class _MasjidRequestScreenState extends State<MasjidRequestScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _contactController = TextEditingController();
  final _imamController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Received'),
        content: const Text(
          'Your masjid onboarding request has been successfully submitted to the Super Admin queue. You will receive an email once approved.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to dashboard
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
        title: Text('Register New Masjid', style: theme.textTheme.titleLarge),
      ),
      body: IslamicPatternBackground(
        opacity: 0.03,
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                _submitRequest();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
              }
            },
            controlsBuilder: (context, details) {
              final isLast = _currentStep == 3;
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLast ? 'SUBMIT REQUEST' : 'CONTINUE'),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('BACK'),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Basic Info
              Step(
                title: const Text('Basic Information', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.editing,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Masjid Name *'),
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Street Address *'),
                      validator: (v) => v!.isEmpty ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City *'),
                            validator: (v) => v!.isEmpty ? 'City is required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _areaController,
                            decoration: const InputDecoration(labelText: 'Area / Sector'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Step 2: Coordinates and Location Picker
              Step(
                title: const Text('Coordinates (GPS)', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.editing,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precision geographic coordinates are required to calculate proximity distance maps for guest users.',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: colorScheme.surface,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Auto-Detect Location (31.5204, 74.3587)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Step 3: Secondary Masjid details
              Step(
                title: const Text('Clerical & Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.editing,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _imamController,
                      decoration: const InputDecoration(labelText: 'Imam / Prayer Lead Name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(labelText: 'Office Contact Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),

              // Step 4: Admin Verification Info
              Step(
                title: const Text('Admin Coordinator verification', style: TextStyle(fontWeight: FontWeight.bold)),
                isActive: _currentStep >= 3,
                state: _currentStep == 3 ? StepState.editing : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Admin Assignee Email *'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid admin email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: 'Coordinator Supporting Notes'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
