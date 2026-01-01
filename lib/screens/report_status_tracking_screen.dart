import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/translation_helper.dart';

class ReportStatusTrackingScreen extends StatelessWidget {
  const ReportStatusTrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final textColor = ThemeHelper.getTextColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final iconColor = ThemeHelper.getIconColor(context);
    final secondaryText = ThemeHelper.getSecondaryTextColor(context);

    final reports = [
      {
        'type': t.suspiciousActivityLabel,
        'date': '2025-06-18',
        'status': t.statusPending,
        'color': Colors.orange,
      },
      {
        'type': t.vandalismLabel,
        'date': '2025-06-15',
        'status': t.statusInReview,
        'color': Colors.blue,
      },
      {
        'type': t.theftLabel,
        'date': '2025-06-10',
        'status': t.statusResolved,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: scaffold,
      appBar: AppBar(
        title: Text(
          t.myReportStatusTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
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
            color: cardColor,
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
                        Text(
                          report['type'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${t.dateLabel}: ${report['date']}',
                          style: TextStyle(color: secondaryText),
                        ),
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
                                side: BorderSide(color: ThemeHelper.getPrimaryColor(context)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(0, 32),
                              ),
                              child: Text(
                                t.detailsCta,
                                style: TextStyle(color: ThemeHelper.getPrimaryColor(context)),
                              ),
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