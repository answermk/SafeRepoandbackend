import 'package:flutter/material.dart';

class ReportStatusTrackingScreen extends StatelessWidget {
  const ReportStatusTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'type': 'Suspicious Activity',
        'date': '2025-06-18',
        'status': 'Pending',
        'color': Colors.orange,
      },
      {
        'type': 'Vandalism',
        'date': '2025-06-15',
        'status': 'In Review',
        'color': Colors.blue,
      },
      {
        'type': 'Theft',
        'date': '2025-06-10',
        'status': 'Resolved',
        'color': Colors.green,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Report Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: (report['color'] as Color).withOpacity(0.15),
                    child: Icon(Icons.report, color: report['color'] as Color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report['type'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Date: ${report['date']}', style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: (report['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                report['status'] as String,
                                style: TextStyle(
                                  color: report['color'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF36599F)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(0, 32),
                              ),
                              child: const Text('Details', style: TextStyle(color: Color(0xFF36599F))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}