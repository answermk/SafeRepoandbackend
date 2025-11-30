import 'package:flutter/material.dart';

class ForumPostScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const ForumPostScreen({Key? key, required this.postData}) : super(key: key);

  @override
  State<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends State<ForumPostScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'initials': 'JD',
      'name': 'Jane Doe',
      'location': 'Oak Street',
      'time': '5 hrs ago',
      'content': 'Great tips Mike! We also found it helpful to have a standardized checklist and log all observations via documented consistency.',
      'helpful': 3,
    },
    {
      'initials': 'PD',
      'name': 'Police Dept',
      'location': 'Police Dept',
      'time': '2 hrs ago',
      'content': 'Excellent suggestions. The police department appreciates organized neighborhood watches and encourages reporting suspicious activity.',
      'helpful': 8,
    },
    {
      'initials': 'AJ',
      'name': 'Alex Johnson',
      'location': 'Maple Ave',
      'time': '1 hr ago',
      'content': 'We\'ve been using walkie-talkies during patrols, which help with communication, especially in areas with spotty cell service.',
      'helpful': 5,
    },
    {
      'initials': 'SM',
      'name': 'Sarah Miller',
      'location': 'Elm Street',
      'time': '45 min ago',
      'content': 'Does anyone have recommendations for good reflective vests that are comfortable for longer patrols?',
      'helpful': 2,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _comments.insert(0, {
        'initials': 'ME', // Current user initials
        'name': 'You',
        'location': 'Your Location',
        'time': 'Just now',
        'content': _commentController.text.trim(),
        'helpful': 0,
      });
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Forum Post', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.postData['title'] ?? 'Forum Post',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildPostCard(),
                const SizedBox(height: 16),
                Text(
                  'Comments (${_comments.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ..._comments.map((comment) => _buildComment(
                  initials: comment['initials'],
                  name: comment['name'],
                  location: comment['location'],
                  time: comment['time'],
                  content: comment['content'],
                  helpful: comment['helpful'],
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment.............',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _postComment,
                  child: const Text('Post Comment', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF36599F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    final postData = widget.postData;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    postData['initials'] ?? 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postData['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${postData['location'] ?? 'Unknown'} • ${postData['time'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              postData['title'] ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              postData['content'] ?? '',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_people, size: 18, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${postData['helpful'] ?? 0} Helpful',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.comment, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${_comments.length} Comments',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment({
    required String initials,
    required String name,
    required String location,
    required String time,
    required String content,
    required int helpful,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('$location • $time', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('Reply', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                const Icon(Icons.emoji_people, size: 18, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Helpful ($helpful)', style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}