import 'package:flutter/material.dart';

class SafetyEducationScreen extends StatelessWidget {
  const SafetyEducationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Safety Education', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildCategoriesGrid(context),
            _buildFeaturedArticles(context),
            _buildHowToReport(context),
            _buildWhatToReport(),
            _buildVideoTutorials(),
            _buildQuickTips(),
            _buildEmergencySteps(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learn. Report. Protect.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Empower yourself with knowledge on responsible reporting',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Color(0xFF8B5CF6), size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      {'title': 'What to Report', 'icon': Icons.report, 'color': Colors.blue},
      {'title': 'How to Report', 'icon': Icons.edit_note, 'color': Colors.green},
      {'title': 'Stay Safe', 'icon': Icons.shield, 'color': Colors.orange},
      {'title': 'Your Rights', 'icon': Icons.gavel, 'color': Colors.purple},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              _navigateToCategory(context, category['title'] as String);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 40,
                    color: category['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildFeaturedArticles(BuildContext context) {
    final articles = [
      {
        'title': 'Understanding Suspicious Behavior',
        'description': 'Learn to identify concerning activities',
        'readTime': '5 min read',
      },
      {
        'title': 'Anonymous Reporting Guide',
        'description': 'How to report safely and anonymously',
        'readTime': '3 min read',
      },
      {
        'title': 'Evidence Collection Best Practices',
        'description': 'Tips for gathering useful evidence',
        'readTime': '7 min read',
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Articles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          ...articles.map((article) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36599F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.article, color: Color(0xFF36599F)),
                ),
                title: Text(
                  article['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      article['description'] as String,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          article['readTime'] as String,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _openArticle(context, article['title'] as String);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHowToReport(BuildContext context) {
    final steps = [
      {
        'title': 'Stay Safe First',
        'detail': 'Find a secure spot; never confront suspects.',
        'icon': Icons.shield,
        'color': Colors.orange,
      },
      {
        'title': 'Capture Details',
        'detail': 'Time, location, people, vehicles, photos/video if safe.',
        'icon': Icons.visibility,
        'color': Colors.blue,
      },
      {
        'title': 'Submit the Report',
        'detail': 'Use the app: select incident type, add description, attach evidence.',
        'icon': Icons.send,
        'color': Colors.green,
      },
      {
        'title': 'Follow Up',
        'detail': 'Check status in My Reports; add more info if requested.',
        'icon': Icons.update,
        'color': Colors.purple,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.how_to_reg, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'How to Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (step['color'] as Color).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      size: 20,
                      color: step['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['detail'] as String,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWhatToReport() {
    final items = [
      {'title': 'Crimes in progress', 'icon': Icons.warning_amber, 'color': Colors.red},
      {'title': 'Suspicious persons/vehicles', 'icon': Icons.visibility, 'color': Colors.orange},
      {'title': 'Threats or harassment', 'icon': Icons.campaign, 'color': Colors.deepOrange},
      {'title': 'Domestic violence', 'icon': Icons.home, 'color': Colors.pink},
      {'title': 'Vandalism or theft', 'icon': Icons.security, 'color': Colors.blue},
      {'title': 'Drug activity', 'icon': Icons.medication_liquid, 'color': Colors.indigo},
      {'title': 'Weapons observed', 'icon': Icons.gavel, 'color': Colors.brown},
      {'title': 'Missing persons', 'icon': Icons.person_search, 'color': Colors.teal},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'What to Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items.map((item) {
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(0.15),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
                ),
                label: Text(item['title'] as String),
                backgroundColor: Colors.grey[100],
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoTutorials() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Video Tutorials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF36599F),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildVideoCard('How to Report Safely', '3:45'),
                _buildVideoCard('Using the App', '2:30'),
                _buildVideoCard('Evidence Tips', '4:15'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(String title, String duration) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.play_circle_filled, size: 50, color: Color(0xFF36599F)),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips() {
    final tips = [
      'Always prioritize your personal safety when observing',
      'Include specific details: time, location, descriptions',
      'Never confront suspicious individuals directly',
      'Use the anonymous option if you feel unsafe',
      'Photos and videos can be powerful evidence',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFFFFA500)),
              SizedBox(width: 8),
              Text(
                'Quick Safety Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmergencySteps() {
    final steps = [
      {
        'title': 'If danger is immediate, call emergency services first.',
        'icon': Icons.call,
        'color': Colors.red,
      },
      {
        'title': 'Move to a safe location and enable Emergency Mode in the app.',
        'icon': Icons.emergency_share,
        'color': Colors.orange,
      },
      {
        'title': 'Share clear location details; keep line open if prompted.',
        'icon': Icons.location_on,
        'color': Colors.blue,
      },
      {
        'title': 'If safe, provide updates (suspect clothing, vehicles, direction).',
        'icon': Icons.directions_run,
        'color': Colors.green,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency, color: Color(0xFF36599F)),
              SizedBox(width: 8),
              Text(
                'Emergency Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF36599F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.map((step) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (step['color'] as Color).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step['icon'] as IconData,
                      size: 20,
                      color: step['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step['title'] as String,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF36599F),
                  ),
                ),
                const SizedBox(height: 12),
                if (category == 'What to Report') ...[
                  const Text(
                    '• Crimes in progress, suspicious persons/vehicles\n'
                    '• Threats, harassment, domestic violence\n'
                    '• Vandalism, theft, drug activity\n'
                    '• Weapons observed, missing persons',
                    style: TextStyle(height: 1.5),
                  ),
                ] else if (category == 'How to Report') ...[
                  const Text(
                    '1) Stay safe; do not confront suspects\n'
                    '2) Capture details: time, location, descriptions\n'
                    '3) Use the app to submit, attach evidence\n'
                    '4) Follow up in My Reports for updates',
                    style: TextStyle(height: 1.5),
                  ),
                ] else if (category == 'Stay Safe') ...[
                  const Text(
                    '• Observe from a safe distance\n'
                    '• Keep your phone silent\n'
                    '• Use anonymous reporting if needed\n'
                    '• Call emergency services if danger is immediate',
                    style: TextStyle(height: 1.5),
                  ),
                ] else if (category == 'Your Rights') ...[
                  const Text(
                    '• You can report anonymously\n'
                    '• You are not required to intervene physically\n'
                    '• Evidence must be gathered safely\n'
                    '• You can request updates on your submissions',
                    style: TextStyle(height: 1.5),
                  ),
                ] else ...[
                  const Text(
                    'Stay safe, be specific, and use the app to report responsibly.',
                    style: TextStyle(height: 1.5),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _openArticle(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening article: $title')),
    );
    // TODO: Navigate to full article page
  }
}