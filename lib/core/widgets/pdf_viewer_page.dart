import 'package:flutter/material.dart';
import 'package:guardiancare/core/constants/app_colors.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

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
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200) {
        setState(() {
          _error = "Failed to load PDF. Status code: ${response.statusCode}";
          _loading = false;
        });
        return;
      }

      final document = await PdfDocument.openData(response.bodyBytes);
      
      setState(() {
        _pdfController = PdfControllerPinch(
          document: Future.value(document),
        );
        _loading = false;
      });
    } catch (e) {
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: tPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: tPrimaryColor),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _loading = true;
                              _error = null;
                            });
                            _loadPDF(widget.pdfUrl);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tPrimaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : PdfViewPinch(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                ),
    );
  }
}
