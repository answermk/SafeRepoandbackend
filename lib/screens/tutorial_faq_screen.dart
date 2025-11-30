import 'package:flutter/material.dart';

class TutorialFaqScreen extends StatefulWidget {
  const TutorialFaqScreen({Key? key}) : super(key: key);

  @override
  State<TutorialFaqScreen> createState() => _TutorialFaqScreenState();
}

class _TutorialFaqScreenState extends State<TutorialFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFaqs = [];
  final List<Map<String, dynamic>> _allFaqs = [
    // Reporting
    {
      'category': 'Reporting',
      'question': 'How do I report a suspicious activity?',
      'answer': 'Tap the "Report Crime" button on the dashboard, select the incident type, provide a detailed description, add any evidence (photos, videos, or audio), and submit. You can choose to report anonymously.',
      'tags': ['report', 'suspicious', 'activity', 'submit']
    },
    {
      'category': 'Reporting',
      'question': 'Can I report anonymously?',
      'answer': 'Yes, you can choose to hide your identity when submitting a report. Simply toggle the "Submit Anonymously" option when creating a report. Your personal information will be protected.',
      'tags': ['anonymous', 'privacy', 'report', 'identity']
    },
    {
      'category': 'Reporting',
      'question': 'What types of incidents can I report?',
      'answer': 'You can report various incidents including: Suspicious Person, Vehicle Activity, Abandoned Item, Theft/Burglary, Vandalism, Drug Activity, Assault/Violence, Noise Disturbance, Trespassing, and Other incidents.',
      'tags': ['incident', 'types', 'report', 'categories']
    },
    {
      'category': 'Reporting',
      'question': 'Can I add photos or videos to my report?',
      'answer': 'Yes! You can add photos, videos, or audio recordings as evidence when creating a report. Tap the evidence icons (Photo, Video, or Audio) to capture or upload media files.',
      'tags': ['evidence', 'photos', 'videos', 'media', 'upload']
    },
    {
      'category': 'Reporting',
      'question': 'How do I track my report status?',
      'answer': 'Go to the "My Reports" section from the dashboard to see the status of all your submitted reports. You can filter by status (Active, Resolved) and search for specific reports.',
      'tags': ['status', 'track', 'reports', 'my reports']
    },
    {
      'category': 'Reporting',
      'question': 'What happens after I submit a report?',
      'answer': 'Your report is reviewed by authorities. You can track its status in "My Reports". Statuses include: SUBMITTED (received), REVIEWING (under investigation), and RESOLVED (case closed).',
      'tags': ['submit', 'review', 'process', 'status']
    },
    {
      'category': 'Reporting',
      'question': 'Can I edit or delete a submitted report?',
      'answer': 'You can view and delete your reports from the "My Reports" section. However, once submitted, reports cannot be edited. If you need to make changes, contact support or submit a new report with updated information.',
      'tags': ['edit', 'delete', 'modify', 'update']
    },
    // Watch Groups
    {
      'category': 'Watch Groups',
      'question': 'How do I join a watch group?',
      'answer': 'Navigate to "My Watch Groups" from the dashboard, then tap "Find More Groups". Browse available groups, search by location or name, and tap "Join Group" to request membership.',
      'tags': ['watch group', 'join', 'community', 'membership']
    },
    {
      'category': 'Watch Groups',
      'question': 'What are watch groups?',
      'answer': 'Watch groups are community safety partnerships where neighbors work together to monitor and report suspicious activities in their area. Members can communicate, share alerts, and coordinate patrols.',
      'tags': ['watch group', 'community', 'safety', 'neighborhood']
    },
    {
      'category': 'Watch Groups',
      'question': 'How do I message other group members?',
      'answer': 'In "My Watch Groups", tap on a group card and select "Message" to open the group chat. You can send messages, share alerts, and communicate with all group members.',
      'tags': ['message', 'chat', 'communication', 'group']
    },
    {
      'category': 'Watch Groups',
      'question': 'Can I create my own watch group?',
      'answer': 'Yes! Contact support to create a new watch group for your neighborhood. You can set coverage areas, schedules, and invite neighbors to join.',
      'tags': ['create', 'new group', 'neighborhood', 'organize']
    },
    // Emergency
    {
      'category': 'Emergency',
      'question': 'How do I use Emergency Mode?',
      'answer': 'Tap the Emergency button on the dashboard to activate Emergency Mode. You can quickly call emergency services (Police, Fire, Ambulance) or non-emergency services. Use this for immediate threats or urgent situations.',
      'tags': ['emergency', 'sos', 'urgent', 'call']
    },
    {
      'category': 'Emergency',
      'question': 'What emergency numbers are available?',
      'answer': 'Emergency Mode provides quick access to: Police Emergency (911), Fire Department (911), Ambulance (911), and Non-Emergency Police (311).',
      'tags': ['emergency', '911', '311', 'numbers', 'services']
    },
    // Community Forum
    {
      'category': 'Community Forum',
      'question': 'How do I create a forum post?',
      'answer': 'Go to "Community Forum" from the dashboard, tap "Create New Post", enter a title and content, optionally add media, and publish. Your post will be visible to the community.',
      'tags': ['forum', 'post', 'create', 'community', 'share']
    },
    {
      'category': 'Community Forum',
      'question': 'Can I comment on forum posts?',
      'answer': 'Yes! Tap on any forum post to view details and comments. You can add your own comments, view responses, and engage with the community.',
      'tags': ['comment', 'forum', 'discussion', 'engage']
    },
    // Profile & Settings
    {
      'category': 'Settings',
      'question': 'How do I change my password?',
      'answer': 'Go to Profile > Account Settings > Security Settings, then tap "Update" next to Change Password. Enter your current password, new password, and confirm it.',
      'tags': ['password', 'change', 'security', 'account']
    },
    {
      'category': 'Settings',
      'question': 'How do I change the app language?',
      'answer': 'Go to Profile > Account Settings > Language Preferences to select your preferred language. The app supports multiple languages including English, Kinyarwanda, and French.',
      'tags': ['language', 'settings', 'preferences', 'localization']
    },
    {
      'category': 'Settings',
      'question': 'How do I enable notifications?',
      'answer': 'Go to Profile > Account Settings > Notification Settings. Toggle on Push Notifications, Email Updates, and Watch Group Alerts to receive updates about your reports and community activity.',
      'tags': ['notifications', 'alerts', 'settings', 'updates']
    },
    {
      'category': 'Settings',
      'question': 'What are accessibility features?',
      'answer': 'Accessibility features help make the app easier to use. Go to Settings > Accessibility to adjust font size, enable high contrast mode, and activate text-to-speech for better usability.',
      'tags': ['accessibility', 'font size', 'contrast', 'text-to-speech']
    },
    // Privacy & Security
    {
      'category': 'Privacy',
      'question': 'Is my personal information secure?',
      'answer': 'Yes, we take privacy seriously. Your data is encrypted, and you can choose anonymous reporting. We never share your information without consent. Review Privacy Settings in Account Settings.',
      'tags': ['privacy', 'security', 'data', 'protection']
    },
    {
      'category': 'Privacy',
      'question': 'Can I control location sharing?',
      'answer': 'Yes, you can control location sharing in Account Settings > Privacy Settings. Toggle location sharing on/off and choose when to share your location with reports.',
      'tags': ['location', 'privacy', 'sharing', 'settings']
    },
    // Offline & Sync
    {
      'category': 'Technical',
      'question': 'Can I report when offline?',
      'answer': 'Yes! Reports created while offline are saved locally and automatically synced when you regain internet connection. Check "Offline Reports Queue" to see pending reports.',
      'tags': ['offline', 'sync', 'queue', 'internet']
    },
    {
      'category': 'Technical',
      'question': 'How do I export my reports?',
      'answer': 'In "My Reports", select a report and tap "Export" to generate a PDF. You can share the PDF via email, messaging apps, or save it to your device.',
      'tags': ['export', 'pdf', 'share', 'download']
    },
    // Support
    {
      'category': 'Support',
      'question': 'How do I contact support?',
      'answer': 'Go to Profile > Help & Support. You can start a live chat, send an email to support@saferreport.com, or call 1-800-SAFERPORT (1-800-723-3776).',
      'tags': ['support', 'contact', 'help', 'assistance']
    },
    {
      'category': 'Support',
      'question': 'What are the support hours?',
      'answer': 'Live chat and phone support are available 24/7. Email support typically responds within 24 hours. For emergencies, always use Emergency Mode.',
      'tags': ['support', 'hours', 'availability', '24/7']
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFaqs);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = _allFaqs;
      } else {
        _filteredFaqs = _allFaqs.where((faq) {
          final question = faq['question'].toString().toLowerCase();
          final answer = faq['answer'].toString().toLowerCase();
          final category = faq['category'].toString().toLowerCase();
          final tags = (faq['tags'] as List).map((t) => t.toString().toLowerCase()).join(' ');
          return question.contains(query) ||
              answer.contains(query) ||
              category.contains(query) ||
              tags.contains(query);
        }).toList();
      }
    });
  }

  List<String> _getCategories() {
    return _allFaqs.map((faq) => faq['category'] as String).toSet().toList();
  }

  List<Map<String, dynamic>> _getFaqsByCategory(String category) {
    return _filteredFaqs.where((faq) => faq['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getCategories();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial & FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF36599F)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${_filteredFaqs.length} result${_filteredFaqs.length != 1 ? 's' : ''} found',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: _filteredFaqs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No FAQs found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different search terms',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_searchController.text.isEmpty) ...[
                  const Text(
                    'Browse by Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                ],
                ...categories.map((category) {
                  final categoryFaqs = _getFaqsByCategory(category);
                  if (categoryFaqs.isEmpty) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_searchController.text.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                color: const Color(0xFF36599F),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF36599F),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF36599F).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${categoryFaqs.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF36599F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...categoryFaqs.map((faq) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            faq['question'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                faq['answer'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (_searchController.text.isEmpty && category != categories.last)
                        const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Reporting':
        return Icons.report;
      case 'Watch Groups':
        return Icons.group;
      case 'Emergency':
        return Icons.emergency;
      case 'Community Forum':
        return Icons.forum;
      case 'Settings':
        return Icons.settings;
      case 'Privacy':
        return Icons.privacy_tip;
      case 'Technical':
        return Icons.build;
      case 'Support':
        return Icons.support_agent;
      default:
        return Icons.help_outline;
    }
  }
}