import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PdfControllerPinch? _pdfController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPDF(widget.pdfUrl);
  }

  Future<void> _loadPDF(String url) async {
    try {
      print("Fetching PDF from: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        setState(() {
          _error = "Failed to load PDF. Code: ${response.statusCode}";
          _loading = false;
        });
        return;
      }

      final document = await PdfDocument.openData(response.bodyBytes);
      setState(() {
        _pdfController = PdfControllerPinch(document: Future.value(document));
        _loading = false;
      });
    } catch (e) {
      print("Error loading PDF: $e");
      setState(() {
        _error = "Error loading PDF: $e";
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : PdfViewPinch(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                ),
    );
  }
}
