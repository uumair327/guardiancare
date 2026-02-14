// Stub file for web platform where pdfx is not supported
// This provides empty implementations to satisfy imports

import 'package:flutter/widgets.dart';

class PdfDocument {
  PdfDocument._();

  static Future<PdfDocument> openData(dynamic data) async {
    throw UnsupportedError('PDF viewing not supported on web');
  }
}

class PdfControllerPinch {
  PdfControllerPinch();
  void dispose() {}
}

class PdfViewPinch extends StatelessWidget {
  const PdfViewPinch({
    super.key,
    required this.controller,
    this.scrollDirection = Axis.vertical,
  });
  final PdfControllerPinch controller;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    // This should never be called on web
    return const SizedBox.shrink();
  }
}
