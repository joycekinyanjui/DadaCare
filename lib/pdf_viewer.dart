import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to open PDF")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        backgroundColor: Colors.lightBlue,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : localPath != null
              ? PDFView(filePath: localPath!)
              : const Center(child: Text("PDF not available")),
    );
  }
}
