import 'dart:typed_data';
import 'dart:developer';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  /// Generate PDF with all reviews for a movie
  Future<Uint8List?> generateReviewsPdf({
    required String movieTitle,
    required List<dynamic> reviews,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildHeader(movieTitle, context),
          footer: (context) => _buildFooter(context),
          build: (context) => _buildReviewsList(reviews),
        ),
      );

      final bytes = await pdf.save();
      log('PDF generated, size: ${bytes.length} bytes');
      return bytes;
    } catch (e) {
      log('Error generating PDF: $e');
      return null;
    }
  }

  pw.Widget _buildHeader(String movieTitle, pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CineView - Movie Reviews',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            movieTitle,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Exported on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
      ),
    );
  }

  List<pw.Widget> _buildReviewsList(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      return [
        pw.Center(
          child: pw.Text(
            'No reviews available',
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
          ),
        ),
      ];
    }

    return reviews.asMap().entries.map((entry) {
      final index = entry.key;
      final review = entry.value;

      final userName = review['user']?['name'] ?? 'Anonymous';
      final rating = review['rating'] ?? 0;
      final content = review['content'] ?? '';
      final reviewContext = review['context'] ?? '';
      final createdAt = review['created_at'] ?? '';

      String formattedDate = 'Unknown';
      if (createdAt.isNotEmpty) {
        try {
          final date = DateTime.parse(createdAt);
          formattedDate = '${date.day}/${date.month}/${date.year}';
        } catch (e) {
          formattedDate = 'Unknown';
        }
      }

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '#${index + 1} - $userName',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formattedDate,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Rating and context
            pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    '★ $rating/10',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber800,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                if (reviewContext.isNotEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      reviewContext,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Content
            pw.Text(
              content,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
            ),
          ],
        ),
      );
    }).toList();
  }
}
