import 'package:flutter/material.dart';

class ChronicIssueCardWidget extends StatelessWidget {
  final Map<String, dynamic> issue;
  const ChronicIssueCardWidget({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(issue['title'] ?? 'Bilinmeyen Sorun', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 4),
            Text(issue['description'] ?? '', style: const TextStyle(fontSize: 13)),
            if (issue['solution'] != null) ...[
              const Divider(),
              Text('Çözüm: ${issue['solution']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87)),
            ]
          ],
        ),
      ),
    );
  }
}