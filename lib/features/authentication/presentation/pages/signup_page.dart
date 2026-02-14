import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/core.dart';
import 'package:guardiancare/features/features.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'parent';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim(),
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: AppDimensions.elevation0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    duration: AppDurations.snackbarMedium,
                  ),
                );
              } else if (state is AuthAuthenticated) {
                // Show email verification message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account created! Please check your email to verify your account before signing in.',
                    ),
                    backgroundColor: AppColors.success,
                    duration: AppDurations.snackbarLong,
                  ),
                );
                // Sign out the user so they must verify email first
                context.read<AuthBloc>().add(const SignOutRequested());
                // Navigate to login
                Future.delayed(AppDurations.navigationDelay, () {
                  if (context.mounted) {
                    context.go('/login');
                  }
                });
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: AppDimensions.paddingAllL,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style:
                            AppTextStyles.h1.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: AppDimensions.spaceS),
                      Text(
                        'Sign up to get started',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.spaceXL),

                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Role Selection - Using RadioGroup for Flutter 3.32+ compatibility
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: AppDimensions.borderRadiusM,
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: AppDimensions.paddingAllM,
                              child: Text(
                                'I am a:',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            RadioGroup<String>(
                              groupValue: _selectedRole,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRole = value;
                                  });
                                }
                              },
                              child: const Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text(UIStrings.parentGuardian),
                                    value: 'parent',
                                  ),
                                  RadioListTile<String>(
                                    title: Text(UIStrings.child),
                                    value: 'child',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          filled: true,
                          fillColor: AppColors.inputBackground,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: AppDimensions.spaceL),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => _handleSignup(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusM,
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),

                      // Login Link
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                              children: const [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
