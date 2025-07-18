import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> referral;

  const PatientDetailsScreen({super.key, required this.referral});

  Future<void> _downloadFile(BuildContext context) async {
    final url = referral['labResultUrl'];
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No lab result attached.')));
      return;
    }

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            _buildDetailTile("Name", referral['name']),
            _buildDetailTile("Age", referral['age']),
            _buildDetailTile("Sex", referral['sex']),
            _buildDetailTile("Condition", referral['condition']),
            _buildDetailTile("Hospital (From)", referral['from']),
            _buildDetailTile("Referred To", referral['to']),
            _buildDetailTile("Notes", referral['notes']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _downloadFile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
              ),
              icon: const Icon(Icons.file_download),
              label: const Text("Download Lab Result"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.medical_information, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value?.toString() ?? 'Not provided'),
      ),
    );
  }
}
