import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';
import 'package:url_launcher/url_launcher.dart';

// Only import pdfx on non-web platforms
import 'package:pdfx/pdfx.dart' if (dart.library.html) 'pdf_viewer_stub.dart';
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
  dynamic _pdfController;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadPDF(widget.pdfUrl);
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadPDF(String url) async {
    if (kIsWeb) return;
    
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
    if (!kIsWeb && _pdfController != null) {
      (_pdfController as PdfControllerPinch).dispose();
    }
    super.dispose();
  }

  void _openPdfInBrowser() async {
    final encodedUrl = Uri.encodeComponent(widget.pdfUrl);
    final viewerUrl = Uri.parse('https://docs.google.com/viewer?url=$encodedUrl&embedded=true');
    
    if (await canLaunchUrl(viewerUrl)) {
      await launchUrl(viewerUrl, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: try opening the PDF directly
      final directUrl = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(directUrl)) {
        await launchUrl(directUrl, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web, show a button to open PDF externally
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        body: Center(
          child: Padding(
            padding: AppDimensions.paddingAllL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: AppDimensions.iconXXL,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppDimensions.spaceM),
                Text(
                  'PDF Viewer',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Click below to view the PDF document.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceL),
                ElevatedButton.icon(
                  onPressed: _openPdfInBrowser,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceL,
                      vertical: AppDimensions.spaceM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Native platforms use pdfx
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: AppDimensions.paddingAllL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppDimensions.iconXXL,
                color: AppColors.error,
              ),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                _error!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceM),
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return PdfViewPinch(
      controller: _pdfController as PdfControllerPinch,
      scrollDirection: Axis.vertical,
    );
  }
}
