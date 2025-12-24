import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ForgotParentalKeyDialog extends StatefulWidget {
  const ForgotParentalKeyDialog({Key? key}) : super(key: key);

  @override
  State<ForgotParentalKeyDialog> createState() => _ForgotParentalKeyDialogState();
}

class _ForgotParentalKeyDialogState extends State<ForgotParentalKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _newKeyController = TextEditingController();
  final TextEditingController _confirmKeyController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureAnswer = true;
  bool _obscureNewKey = true;
  bool _obscureConfirmKey = true;
  int _step = 1; // 1: Answer question, 2: Set new key
  String? _securityQuestion;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _newKeyController.dispose();
    _confirmKeyController.dispose();
    super.dispose();
  }

  String _hashString(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  Future<void> _loadSecurityQuestion() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('consents')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _securityQuestion = doc.data()?['securityQuestion'] as String?;
        });
      }
    } catch (e) {
      print('Error loading security question: $e');
    }
  }

  Future<void> _verifyAnswer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final doc = await FirebaseFirestore.instance
          .collection('consents')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('No consent data found');
      }

      final storedAnswerHash = doc.data()?['securityAnswer'] as String?;
      final enteredAnswerHash = _hashString(_answerController.text.toLowerCase().trim());

      if (storedAnswerHash == enteredAnswerHash) {
        setState(() {
          _step = 2;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect answer. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetKey() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Update parental key in Firestore
      await FirebaseFirestore.instance
          .collection('consents')
          .doc(user.uid)
          .update({
        'parentalKey': _hashString(_newKeyController.text),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop(true); // Return true to indicate success
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parental key reset successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answer Security Question',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        if (_securityQuestion != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: AppDimensions.borderRadiusS,
              border: Border.all(color: AppColors.primaryLight),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _securityQuestion!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _answerController,
            decoration: InputDecoration(
              labelText: 'Your Answer',
              hintText: 'Enter your answer',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(Icons.question_answer, color: AppColors.primary),
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
                return 'Please enter your answer';
              }
              return null;
            },
          ),
        ] else ...[
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set New Parental Key',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newKeyController,
          decoration: InputDecoration(
            labelText: 'New Parental Key',
            hintText: 'Min 4 characters',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(_obscureNewKey ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureNewKey = !_obscureNewKey;
                });
              },
            ),
          ),
          obscureText: _obscureNewKey,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a new key';
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
            labelText: 'Confirm New Key',
            hintText: 'Re-enter your key',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
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
              return 'Please confirm your key';
            }
            if (value != _newKeyController.text) {
              return 'Keys do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(Icons.lock_reset, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text('Forgot Parental Key'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: _step == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_step == 1) {
                    _verifyAnswer();
                  } else {
                    _resetKey();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_step == 1 ? 'Verify' : 'Reset Key'),
        ),
      ],
    );
  }
}
