import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _mediaFileName;

  void _pickMedia() async {
    // Placeholder for media picker
    setState(() {
      _mediaFileName = 'example_photo.jpg';
    });
  }

  void _submitPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Submitted!'),
        content: const Text('Your post has been submitted to the community forum.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    _titleController.clear();
    _contentController.clear();
    setState(() => _mediaFileName = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter post title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Content', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your post here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickMedia,
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  label: const Text('Add Media', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF36599F),
                  ),
                ),
                const SizedBox(width: 12),
                if (_mediaFileName != null)
                  Expanded(
                    child: Text(
                      _mediaFileName!,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                  _submitPost();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF36599F),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Submit Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}