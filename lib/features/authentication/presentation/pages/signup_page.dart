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
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.background,
          elevation: AppDimensions.elevation0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.primary),
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
                  SnackBar(
                    content: const Text(
                      'Account created! Please check your email to verify your account before signing in.',
                    ),
                    backgroundColor: context.colors.success,
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
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(context.colors.primary),
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
                        style: AppTextStyles.h1
                            .copyWith(color: context.colors.primary),
                      ),
                      const SizedBox(height: AppDimensions.spaceS),
                      Text(
                        'Sign up to get started',
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.spaceXL),

                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle:
                              TextStyle(color: context.colors.textSecondary),
                          prefixIcon: Icon(Icons.person_outline,
                              color: context.colors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.textSecondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.primary),
                          ),
                          filled: true,
                          fillColor: context.colors.inputBackground,
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
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle:
                              TextStyle(color: context.colors.textSecondary),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: context.colors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.textSecondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.primary),
                          ),
                          filled: true,
                          fillColor: context.colors.inputBackground,
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

                      // Role Selection
                      Container(
                        decoration: BoxDecoration(
                          color: context.colors.inputBackground,
                          borderRadius: AppDimensions.borderRadiusM,
                          border: Border.all(color: context.colors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: AppDimensions.paddingAllM,
                              child: Text(
                                'I am a:',
                                style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.textPrimary),
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
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text(UIStrings.parentGuardian,
                                        style: TextStyle(
                                            color: context.colors.textPrimary)),
                                    value: 'parent',
                                    activeColor: context.colors.primary,
                                  ),
                                  RadioListTile<String>(
                                    title: Text(UIStrings.child,
                                        style: TextStyle(
                                            color: context.colors.textPrimary)),
                                    value: 'child',
                                    activeColor: context.colors.primary,
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
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle:
                              TextStyle(color: context.colors.textSecondary),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: context.colors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: context.colors.textSecondary,
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.textSecondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.primary),
                          ),
                          filled: true,
                          fillColor: context.colors.inputBackground,
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
                        style: TextStyle(color: context.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle:
                              TextStyle(color: context.colors.textSecondary),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: context.colors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: context.colors.textSecondary,
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.textSecondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppDimensions.borderRadiusM,
                            borderSide:
                                BorderSide(color: context.colors.primary),
                          ),
                          filled: true,
                          fillColor: context.colors.inputBackground,
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
                            backgroundColor: context.colors.primary,
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
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.colors.textSecondary),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: context.colors.primary,
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
