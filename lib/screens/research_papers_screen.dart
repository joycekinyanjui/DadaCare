// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // you’ll need this dependency
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ResearchPapersScreen extends StatefulWidget {
  const ResearchPapersScreen({super.key});

  @override
  State<ResearchPapersScreen> createState() => _ResearchPapersScreenState();
}

class _ResearchPapersScreenState extends State<ResearchPapersScreen> {
  List<Map<String, dynamic>> papers = [];
  bool isLoading = false;
  String searchQuery = "cervical cancer";
  final searchController = TextEditingController(text: "cervical cancer");

  @override
  void initState() {
    super.initState();
    fetchPapers(searchQuery);
  }

  Future<void> fetchPapers(String query) async {
    setState(() {
      isLoading = true;
      papers.clear();
    });

    final url = Uri.parse(
      "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=${Uri.encodeComponent(query)}&format=json&pageSize=30",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data["resultList"]["result"];

        setState(() {
          papers =
              results.map<Map<String, dynamic>>((item) {
                String? pdfLink;
                if (item["fullTextUrlList"] != null &&
                    item["fullTextUrlList"]["fullTextUrl"].isNotEmpty) {
                  final urls =
                      item["fullTextUrlList"]["fullTextUrl"] as List<dynamic>;
                  final pdfEntry = urls.firstWhere(
                    (e) => e["documentStyle"] == "pdf",
                    orElse: () => {},
                  );
                  if (pdfEntry.isNotEmpty) {
                    pdfLink = pdfEntry["url"];
                  }
                }

                return {
                  "title": item["title"],
                  "authors": item["authorString"],
                  "journal": item["journalTitle"],
                  "year": item["pubYear"].toString(),
                  "doi":
                      item["doi"] != null
                          ? "https://doi.org/${item["doi"]}"
                          : "",
                  "pdf": pdfLink,
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openPDF(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => PDFViewPage(file.path)));
    } catch (e) {
      debugPrint("Error opening PDF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to open PDF")));
    }
  }

  void _openExternal(String url) async {
    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No link available")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 100, 169, 201),
        title: const Text("Cervical Cancer Research Papers"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search research topic...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 121, 179, 206),
                  ),
                  onPressed: () => fetchPapers(searchController.text.trim()),
                  child: const Text("Search"),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : papers.isEmpty
                    ? const Center(child: Text("No papers found"))
                    : ListView.builder(
                      itemCount: papers.length,
                      itemBuilder: (context, index) {
                        final paper = papers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              paper["title"] ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${paper["authors"] ?? "Unknown authors"}\n${paper["journal"] ?? ""} (${paper["year"]})",
                            ),
                            onTap: () {
                              if (paper["pdf"] != null &&
                                  paper["pdf"]!.isNotEmpty) {
                                _openPDF(paper["pdf"]!);
                              } else if (paper["doi"] != null &&
                                  paper["doi"]!.isNotEmpty) {
                                _openExternal(paper["doi"]!);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No link available"),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class PDFViewPage extends StatelessWidget {
  final String path;
  const PDFViewPage(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Research Paper")),
      body: PDFView(filePath: path),
    );
  }
}
