import 'package:flutter/material.dart';

/// Widget that allows restarting the entire app
/// Following Clean Architecture - Infrastructure layer widget
/// 
/// Usage:
/// ```dart
/// AppRestartWidget.restartApp(context);
/// ```
class AppRestartWidget extends StatefulWidget {

  const AppRestartWidget({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();

  /// Restart the entire app by rebuilding from root
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWidgetState>()?.restartApp();
  }
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

