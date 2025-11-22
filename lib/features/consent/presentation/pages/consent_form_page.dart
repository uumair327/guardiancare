import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentFormPage extends StatefulWidget {
  final VoidCallback onSubmit;

  const ConsentFormPage({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ConsentFormPage> createState() => _ConsentFormPageState();
}

class _ConsentFormPageState extends State<ConsentFormPage> {
  final TextEditingController _keyController = TextEditingController();
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _submitConsent() async {
    // Validate parental key
    if (_keyController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parental key must be at least 4 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parental_key', _keyController.text);
    widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Parental Consent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This app is designed for children. Please set up a parental key to protect your child.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Set Parental Key (min 4 characters)',
                      hintText: 'Letters, numbers, or both',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('I agree to the terms and conditions'),
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _agreedToTerms && _keyController.text.length == 4
                        ? _submitConsent
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
