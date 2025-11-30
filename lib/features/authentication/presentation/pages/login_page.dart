import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardiancare/core/di/injection_container.dart' as di;
import 'package:guardiancare/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_event.dart';
import 'package:guardiancare/features/authentication/presentation/bloc/auth_state.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  Future<void> _showTermsAndConditions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 16.0,
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(
              color: tPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please read and accept the following terms and conditions to proceed.',
                ),
                SizedBox(height: 10),
                Text(
                  '• Your data will be securely stored.\n'
                  '• You agree to follow the platform rules and regulations.\n'
                  '• You acknowledge the responsibility of safeguarding your account.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'I Agree',
                style: TextStyle(color: tPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger Google sign-in via BLoC
                context.read<AuthBloc>().add(const SignInWithGoogleRequested());
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: tPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>()..add(const CheckAuthStatus()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            // Note: Navigation is handled by GoRouter redirect
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(tPrimaryColor),
                ),
              );
            }

            return const _LoginForm();
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInWithEmailRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  Future<void> _showTermsAndConditions(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 16.0,
          title: const Text(
            'Terms and Conditions',
            style: TextStyle(
              color: tPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please read and accept the following terms and conditions to proceed.',
                ),
                SizedBox(height: 10),
                Text(
                  '• Your data will be securely stored.\n'
                  '• You agree to follow the platform rules and regulations.\n'
                  '• You acknowledge the responsibility of safeguarding your account.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'I Agree',
                style: TextStyle(color: tPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger Google sign-in via BLoC
                context.read<AuthBloc>().add(const SignInWithGoogleRequested());
              },
            ),
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: tPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo and Title
          Image.asset(
            'assets/logo/logo.png',
            width: 120,
          ),
          const SizedBox(height: 8),
          const Text(
            'A Children of India App',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome Back',
            style: TextStyle(
              color: tPrimaryColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to continue',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Email/Password Login Form - COMMENTED OUT
          // Only Google Sign-In is enabled
          /* 
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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
                ),
                const SizedBox(height: 16),

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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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
                ),
                const SizedBox(height: 8),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/password-reset');
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: tPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handleEmailLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Divider with "OR"
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 24),
          */

          // Google Sign In Button - PRIMARY AUTHENTICATION METHOD
          SizedBox(
            height: 50,
            width: double.infinity,
            child: SignInButton(
              Buttons.google,
              text: "Sign In With Google",
              onPressed: () {
                _showTermsAndConditions(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info text
          Text(
            'Sign in with your Google account to continue',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Sign Up Link - COMMENTED OUT
          // Only Google Sign-In is enabled
          /*
          TextButton(
            onPressed: () {
              context.push('/signup');
            },
            child: const Text.rich(
              TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(
                      color: tPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}
