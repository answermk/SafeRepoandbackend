import 'package:flutter/material.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Sarah Johnson',
      'isMe': false,
      'text': 'Has anyone noticed increased foot traffic near the school this week?',
      'time': '2:30 PM',
    },
    {
      'sender': 'Me',
      'isMe': true,
      'text': 'I saw two unfamiliar individuals taking photos of the school building yesterday afternoon.',
      'time': '2:32 PM',
    },
    {
      'sender': 'Mike Chen',
      'isMe': false,
      'text': 'I\'ll add extra patrols during school dismissal time this week.',
      'time': '2:35 PM',
    },
    {
      'sender': 'Me',
      'isMe': true,
      'text': 'Thanks Mike. I\'ll join you on Wednesday.',
      'time': '2:32 PM',
    },
    {
      'sender': 'Officer Martinez',
      'isMe': false,
      'text': 'We\'ve received your reports and will have extra patrols in the area.',
      'time': '2:40 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildChatList()),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF36599F),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Chat',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Oak Street Watch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final msg = _messages[i];
        return _buildChatBubble(msg);
      },
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isMe = msg['isMe'] as bool;
    final isOfficer = msg['sender'] == 'Officer Martinez';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF36599F) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: Colors.blue.shade100, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                msg['sender'],
                style: TextStyle(
                  color: isOfficer ? const Color(0xFF36599F) : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            if (!isMe) const SizedBox(height: 2),
            Text(
              msg['text'],
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg['time'],
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black45,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF36599F)),
            onPressed: () {
              // Add send logic here
            },
          ),
        ],
      ),
    );
  }
}