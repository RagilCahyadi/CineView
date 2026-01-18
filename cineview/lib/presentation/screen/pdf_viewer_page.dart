import 'dart:typed_data';
import 'package:cineview/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const PdfViewerPage({super.key, required this.pdfBytes, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: 'reviews_${title.replaceAll(' ', '_')}.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        onError: (context, error) => Center(
          child: Text(
            'Error displaying PDF: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
