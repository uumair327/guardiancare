import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardiancare/src/constants/colors.dart';
import 'package:guardiancare/src/features/consent/services/attempt_limiting_service.dart';
import 'dart:ui';

class EnhancedPasswordDialog extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onForgotPassword;
  final LockoutStatus? lockoutStatus;

  const EnhancedPasswordDialog({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    required this.onForgotPassword,
    this.lockoutStatus,
  });

  @override
  State<EnhancedPasswordDialog> createState() => _EnhancedPasswordDialogState();
}

class _EnhancedPasswordDialogState extends State<EnhancedPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  Timer? _lockoutTimer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startLockoutTimer();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _startLockoutTimer() {
    final status = widget.lockoutStatus;
    if (status != null && status.isLockedOut && status.remainingTime != null) {
      _remainingTime = status.remainingTime!;
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
            if (_remainingTime.isNegative || _remainingTime == Duration.zero) {
              _lockoutTimer?.cancel();
              // Optionally close dialog when lockout expires
              // Navigator.of(context).pop();
            }
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.lockoutStatus ?? LockoutStatus.normal();
    final canSubmit = !status.isLockedOut && !_isSubmitting;

    return Dialog(
      backgroundColor: tTransparentBackground,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: tTransparentBackground),
            ),
          ),
          Center(
            child: Material(
              color: tTransparentBackground,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: tCardBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(status),
                    const SizedBox(height: 12),
                    _buildStatusMessage(status),
                    if (!status.isLockedOut) ...[
                      const SizedBox(height: 12),
                      _buildPasswordField(canSubmit),
                      const SizedBox(height: 5),
                      _buildForgotPasswordLink(),
                    ],
                    const SizedBox(height: 15),
                    _buildActionButtons(canSubmit, status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LockoutStatus status) {
    String title;
    Color titleColor;

    switch (status.state) {
      case LockoutState.normal:
        title = "Enter Parental Key";
        titleColor = tPrimaryColor;
        break;
      case LockoutState.warning:
        title = "Verification Required";
        titleColor = Colors.orange;
        break;
      case LockoutState.lockedOut:
        title = "Access Temporarily Blocked";
        titleColor = Colors.red;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (status.hasWarning || status.isLockedOut)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              status.isLockedOut ? Icons.lock : Icons.warning,
              color: titleColor,
              size: 20,
            ),
          ),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(LockoutStatus status) {
    if (status.isNormal) return const SizedBox.shrink();

    Color messageColor;
    IconData iconData;
    String displayMessage = status.message;

    switch (status.messageType) {
      case LockoutMessageType.info:
        messageColor = Colors.blue;
        iconData = Icons.info_outline;
        break;
      case LockoutMessageType.warning:
        messageColor = Colors.orange;
        iconData = Icons.warning_amber;
        break;
      case LockoutMessageType.error:
        messageColor = Colors.red;
        iconData = Icons.timer;
        // Show live countdown for lockout
        if (status.isLockedOut && _remainingTime > Duration.zero) {
          final minutes = _remainingTime.inMinutes;
          final seconds = _remainingTime.inSeconds % 60;
          displayMessage = 'Too many failed attempts. Try again in ${minutes}:${seconds.toString().padLeft(2, '0')}.';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: messageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: messageColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: messageColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayMessage,
              style: TextStyle(
                fontSize: 12,
                color: messageColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status.isLockedOut && _remainingTime > Duration.zero)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: messageColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 11,
                  color: messageColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(bool canSubmit) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: canSubmit,
      onFieldSubmitted: canSubmit ? (_) => _handleSubmit() : null,
      decoration: InputDecoration(
        labelText: "Parental Key",
        labelStyle: TextStyle(
          color: canSubmit ? tPrimaryColor : Colors.grey,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: tPrimaryColor),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canSubmit)
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: widget.onForgotPassword,
          child: const Text(
            "forgot parental key",
            style: TextStyle(
              fontSize: 11,
              color: Color.fromARGB(255, 0, 105, 190),
              decoration: TextDecoration.underline,
              decorationColor: Color.fromARGB(255, 0, 105, 190),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool canSubmit, LockoutStatus status) {
    if (status.isLockedOut) {
      return SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: widget.onCancel,
          child: const Text(
            "OK",
            style: TextStyle(color: tPrimaryColor),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          onPressed: canSubmit ? _handleSubmit : null,
          child: Text(
            "Unlock",
            style: TextStyle(
              color: canSubmit ? tPrimaryColor : Colors.grey,
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onCancel,
          child: const Text(
            "Cancel",
            style: TextStyle(color: tTextPrimary),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_isSubmitting || _passwordController.text.trim().isEmpty) return;

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    setState(() {
      _isSubmitting = true;
    });

    // Add a small delay to show loading state
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.onSubmit(_passwordController.text);
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    });
  }
}