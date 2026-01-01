import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/feedback_service.dart';
import '../services/contact_service.dart';
import 'support_chat_screen.dart';
import 'tutorial_faq_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  
  // Admin contact info
  String _adminEmail = 'support@saferreport.com';
  String _adminPhone = '1-800-SAFERPORT';
  String _adminPhoneNumber = '18007233776';
  bool _isLoadingContact = true;

  @override
  void initState() {
    super.initState();
    _loadAdminContactInfo();
  }

  Future<void> _loadAdminContactInfo() async {
    setState(() {
      _isLoadingContact = true;
    });

    try {
      final result = await ContactService.getAdminContactInfo();
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _adminEmail = data['email']?.toString() ?? 'support@saferreport.com';
          final phone = data['phoneNumber']?.toString() ?? '18007233776';
          _adminPhoneNumber = phone;
          // Format phone for display
          if (phone.length == 10) {
            _adminPhone = '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
          } else if (phone.length == 11 && phone.startsWith('1')) {
            _adminPhone = '1-${phone.substring(1, 4)}-${phone.substring(4, 7)}-${phone.substring(7)}';
          } else {
            _adminPhone = phone;
          }
          _isLoadingContact = false;
        });
      } else {
        setState(() {
          _isLoadingContact = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingContact = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Get assistance and answers', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.black54),
                  const SizedBox(height: 8),
                  const Text('Need Help?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 4),
                  const Text("We're here to assist you 24/7", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportChatScreen(),
                        ),
                      );
                    },
                    child: const Text('Start Live Chat', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF36599F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickHelpSection(context),
            const SizedBox(height: 16),
            _buildContactOptionsSection(context),
            const SizedBox(height: 16),
            _buildFeedbackSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.help_outline_sharp, color: Colors.green),
            SizedBox(width: 8),
            Text('Quick Help', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        const SizedBox(height: 8),
        _buildHelpTile(
          context,
          icon: Icons.question_answer,
          title: 'Frequently Asked Questions',
          subtitle: 'Common questions and answers',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TutorialFaqScreen(),
              ),
            );
          },
        ),
        _buildHelpTile(
          context,
          icon: Icons.rule,
          title: 'Reporting Guidelines',
          subtitle: 'Best practices for safety reporting',
        ),
        _buildHelpTile(
          context,
          icon: Icons.group,
          title: 'Community Guidelines',
          subtitle: 'Rules and expectations',
        ),
      ],
    );
  }

  Widget _buildHelpTile(BuildContext context, {required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  Widget _buildContactOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.contact_phone, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Contact Options', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.email_rounded, color: Colors.red),
            title: const Text('Email Support'),
            subtitle: _isLoadingContact
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_adminEmail),
            trailing: ElevatedButton(
              onPressed: _isLoadingContact ? null : () async {
                final subject = 'Support Request - Safe Report App';
                final body = 'Hello Safe Report Support Team,\n\n';
                
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: _adminEmail,
                  query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
                );
                
                try {
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open email client'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Email', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF36599F),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone, color: Colors.blue),
            title: const Text('Phone Support'),
            subtitle: _isLoadingContact
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_adminPhone),
            trailing: ElevatedButton(
              onPressed: _isLoadingContact ? null : () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: _adminPhoneNumber);
                
                try {
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    // Fallback: try to launch anyway for emergency/support numbers
                    await launchUrl(phoneUri);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not make phone call: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Call', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF36599F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.feedback, color: Colors.black87),
            SizedBox(width: 8),
            Text('Send Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          enabled: !_isSubmitting,
          decoration: InputDecoration(
            hintText: 'Tell us how we can improve...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: _isSubmitting ? Colors.grey[100] : Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmitFeedback,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF36599F),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmitFeedback() async {
    final message = _feedbackController.text.trim();
    
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback must be at least 10 characters long'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final result = await FeedbackService.submitFeedback(message);
      
      if (result['success'] == true) {
        _feedbackController.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback has been submitted successfully.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to submit feedback'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}