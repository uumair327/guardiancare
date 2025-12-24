import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EnhancedConsentFormPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const EnhancedConsentFormPage({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EnhancedConsentFormPage> createState() => _EnhancedConsentFormPageState();
}

class _EnhancedConsentFormPageState extends State<EnhancedConsentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _parentEmailController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _confirmKeyController = TextEditingController();
  final TextEditingController _securityAnswerController = TextEditingController();
  
  bool _agreedToTerms = false;
  bool _isChildAbove12 = false;
  bool _obscureKey = true;
  bool _obscureConfirmKey = true;
  bool _obscureAnswer = true;
  int _currentStep = 0;
  
  String? _selectedSecurityQuestion;
  final List<String> _securityQuestions = [
    'What is your mother\'s maiden name?',
    'What was the name of your first pet?',
    'What city were you born in?',
    'What is your favorite book?',
    'What was your childhood nickname?',
  ];

  @override
  void dispose() {
    _parentEmailController.dispose();
    _childNameController.dispose();
    _keyController.dispose();
    _confirmKeyController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  String _hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  Future<void> _submitConsent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('consents').doc(user.uid).set({
        'parentEmail': _parentEmailController.text.trim(),
        'childName': _childNameController.text.trim(),
        'isChildAbove12': _isChildAbove12,
        'parentalKey': _hashString(_keyController.text),
        'securityQuestion': _selectedSecurityQuestion,
        'securityAnswer': _hashString(_securityAnswerController.text.toLowerCase().trim()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      widget.onSubmit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parent Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _parentEmailController,
          decoration: const InputDecoration(
            labelText: 'Parent Email',
            hintText: 'parent@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email, color: tPrimaryColor),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter parent email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _childNameController,
          decoration: const InputDecoration(
            labelText: 'Child Name',
            hintText: 'Enter child\'s name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.child_care, color: tPrimaryColor),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter child name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Is child above 12 years old?'),
          value: _isChildAbove12,
          onChanged: (value) {
            setState(() {
              _isChildAbove12 = value;
            });
          },
          activeColor: tPrimaryColor,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Parental Key',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This key will be used to access restricted features like the forum.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _keyController,
          decoration: InputDecoration(
            labelText: 'Parental Key',
            hintText: 'Min 4 characters',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock, color: tPrimaryColor),
            suffixIcon: IconButton(
              icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureKey = !_obscureKey;
                });
              },
            ),
          ),
          obscureText: _obscureKey,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a parental key';
            }
            if (value.length < 4) {
              return 'Key must be at least 4 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmKeyController,
          decoration: InputDecoration(
            labelText: 'Confirm Parental Key',
            hintText: 'Re-enter your key',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline, color: tPrimaryColor),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmKey ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureConfirmKey = !_obscureConfirmKey;
                });
              },
            ),
          ),
          obscureText: _obscureConfirmKey,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your parental key';
            }
            if (value != _keyController.text) {
              return 'Keys do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Question',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This will help you recover your parental key if you forget it.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedSecurityQuestion,
          decoration: const InputDecoration(
            labelText: 'Select Security Question',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.help_outline, color: tPrimaryColor),
          ),
          items: _securityQuestions.map((question) {
            return DropdownMenuItem(
              value: question,
              child: Text(question, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSecurityQuestion = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a security question';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _securityAnswerController,
          decoration: InputDecoration(
            labelText: 'Your Answer',
            hintText: 'Enter your answer',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.question_answer, color: tPrimaryColor),
            suffixIcon: IconButton(
              icon: Icon(_obscureAnswer ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureAnswer = !_obscureAnswer;
                });
              },
            ),
          ),
          obscureText: _obscureAnswer,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an answer';
            }
            if (value.length < 2) {
              return 'Answer must be at least 2 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          title: const Text('I agree to the terms and conditions'),
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
          activeColor: tPrimaryColor,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.family_restroom,
                      size: 60,
                      color: tPrimaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Parental Consent Setup',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: tPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Protect your child with parental controls',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Step Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: index <= _currentStep
                                  ? tPrimaryColor
                                  : Colors.grey[300],
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index <= _currentStep
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (index < 2)
                              Container(
                                width: 40,
                                height: 2,
                                color: index < _currentStep
                                    ? tPrimaryColor
                                    : Colors.grey[300],
                              ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    
                    // Step Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentStep == 0
                          ? _buildStep1()
                          : _currentStep == 1
                              ? _buildStep2()
                              : _buildStep3(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            child: const Text('Back'),
                          )
                        else
                          const SizedBox.shrink(),
                        
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStep < 2) {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            } else {
                              _submitConsent();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _currentStep < 2 ? 'Next' : 'Submit',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
