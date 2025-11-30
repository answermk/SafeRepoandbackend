import 'package:flutter/material.dart';

class MediaGalleryScreen extends StatelessWidget {
  const MediaGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaItems = [
      {'type': 'photo', 'url': '', 'label': 'Photo 1'},
      {'type': 'video', 'url': '', 'label': 'Video 1'},
      {'type': 'audio', 'url': '', 'label': 'Audio 1'},
      {'type': 'photo', 'url': '', 'label': 'Photo 2'},
      {'type': 'video', 'url': '', 'label': 'Video 2'},
    ];

    IconData _iconForType(String type) {
      switch (type) {
        case 'photo':
          return Icons.photo;
        case 'video':
          return Icons.videocam;
        case 'audio':
          return Icons.audiotrack;
        default:
          return Icons.insert_drive_file;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: mediaItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = mediaItems[index];
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(item['label'] as String),
                    content: Center(
                      child: Icon(_iconForType(item['type'] as String), size: 64, color: const Color(0xFF36599F)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100, width: 1.2),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(_iconForType(item['type'] as String), size: 48, color: const Color(0xFF36599F)),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}