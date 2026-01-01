import 'package:flutter/material.dart';
import '../services/ai_chat_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _aiServiceAvailable = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _isLoading = true;
    });

    // Check AI service status
    final status = await AIChatService.checkAIServiceStatus();
    setState(() {
      _aiServiceAvailable = status['available'] ?? false;
      _isLoading = false;
    });

    // Add welcome message
    if (mounted) {
      setState(() {
        _messages.insert(0, {
          'id': 'welcome',
          'sender': 'AI Assistant',
          'senderInitials': 'AI',
          'message': _aiServiceAvailable
              ? 'Hello! I\'m your Safe Report AI assistant. How can I help you today?'
              : 'Hello! Thank you for contacting Safe Report support. How can we assist you today?',
          'timestamp': DateTime.now(),
          'isFromSupport': true,
        });
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) {
      return;
    }

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _messages.insert(0, {
        'id': userMessageId,
        'sender': 'You',
        'senderInitials': 'ME',
        'message': userMessage,
        'timestamp': DateTime.now(),
        'isFromSupport': false,
        'isUser': true,
      });
      _isSending = true;
      _errorMessage = null;
    });

    // Scroll to show new message
    _scrollToTop();

    // Add typing indicator
    final typingId = 'typing_${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _messages.insert(0, {
        'id': typingId,
        'sender': 'AI Assistant',
        'senderInitials': 'AI',
        'message': '...',
        'timestamp': DateTime.now(),
        'isFromSupport': true,
        'isTyping': true,
      });
    });
    _scrollToTop();

    try {
      // Build conversation history (excluding typing indicator)
      final conversationHistory = _messages
          .where((msg) => msg['isTyping'] != true && msg['id'] != typingId)
          .take(20)
          .map((msg) => {
                'isUser': msg['isFromSupport'] == false,
                'message': msg['message'],
                'content': msg['message'],
              })
          .toList()
          .reversed
          .toList();

      // Call AI service
      final result = await AIChatService.sendMessage(
        userMessage,
        conversationHistory: conversationHistory,
      );

      // Remove typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == typingId);
      });

      if (result['success'] == true) {
        // Add AI response
        setState(() {
          _messages.insert(0, {
            'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
            'sender': 'AI Assistant',
            'senderInitials': 'AI',
            'message': result['response'] ?? 'I apologize, but I couldn\'t generate a response.',
            'timestamp': DateTime.now(),
            'isFromSupport': true,
          });
          _isSending = false;
        });
      } else {
        // Show error message with more helpful text
        final errorMsg = result['error'] ?? 'I apologize, but I\'m having trouble responding right now.';
        String userFriendlyError = errorMsg;
        
        // Check if it's an API key error
        if (errorMsg.toLowerCase().contains('api key') || 
            errorMsg.toLowerCase().contains('invalid') ||
            errorMsg.toLowerCase().contains('gemini')) {
          userFriendlyError = 'The AI service is currently unavailable. Please contact support directly via email or phone for assistance.';
        }
        
        setState(() {
          _messages.insert(0, {
            'id': 'error_${DateTime.now().millisecondsSinceEpoch}',
            'sender': 'AI Assistant',
            'senderInitials': 'AI',
            'message': userFriendlyError,
            'timestamp': DateTime.now(),
            'isFromSupport': true,
            'isError': true,
          });
          _isSending = false;
          _errorMessage = result['error'] ?? 'Unknown error';
        });

        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to get AI response'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Remove typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == typingId);
        _isSending = false;
        _errorMessage = e.toString();
      });

      // Show error message
      setState(() {
        _messages.insert(0, {
          'id': 'error_${DateTime.now().millisecondsSinceEpoch}',
          'sender': 'AI Assistant',
          'senderInitials': 'AI',
          'message': 'I apologize, but I encountered an error. Please check your connection and try again.',
          'timestamp': DateTime.now(),
          'isFromSupport': true,
          'isError': true,
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Support Chat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  _aiServiceAvailable
                      ? 'AI Assistant • Online'
                      : 'Support Team • Available',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFF36599F),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isCurrentUser = !message['isFromSupport'] as bool;
                          final isTyping = message['isTyping'] == true;
                          return _buildMessageBubble(message, isCurrentUser, isTyping: isTyping);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is here to help!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    bool isCurrentUser, {
    bool isTyping = false,
  }) {
    final isError = message['isError'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF36599F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _aiServiceAvailable ? Icons.smart_toy : Icons.support_agent,
                color: const Color(0xFF36599F),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(0xFF36599F)
                    : isError
                        ? Colors.red[50]
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isError
                    ? Border.all(color: Colors.red[300]!, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message['sender'] ?? 'AI Assistant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isError
                            ? Colors.red[700]
                            : const Color(0xFF36599F),
                      ),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  if (isTyping)
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF36599F),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI is typing...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      message['message'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isCurrentUser
                            ? Colors.white
                            : isError
                                ? Colors.red[900]
                                : Colors.black87,
                      ),
                    ),
                  if (!isTyping) const SizedBox(height: 4),
                  if (!isTyping)
                    Text(
                      _formatTimestamp(message['timestamp'] as DateTime),
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrentUser
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF36599F).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text(
                'ME',
                style: TextStyle(
                  color: Color(0xFF36599F),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF36599F), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _isSending
                    ? Colors.grey[400]
                    : const Color(0xFF36599F),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

