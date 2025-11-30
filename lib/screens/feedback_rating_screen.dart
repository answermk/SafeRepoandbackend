import 'package:flutter/material.dart';

class FeedbackRatingScreen extends StatefulWidget {
  const FeedbackRatingScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text('Your feedback has been submitted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    _controller.clear();
    setState(() => _rating = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Rating', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('How would you rate your experience?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(
                  Icons.star,
                  color: _rating > index ? const Color(0xFFFFC107) : Colors.grey.shade300,
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              )),
            ),
            const SizedBox(height: 24),
            const Text('Additional Comments', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us more... (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _rating == 0 ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Submit Feedback', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}