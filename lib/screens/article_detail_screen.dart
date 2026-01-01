import 'package:flutter/material.dart';
import '../services/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final String? title;
  final String? description;

  const ArticleDetailScreen({
    Key? key,
    required this.articleId,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Map<String, dynamic>? _article;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ArticleService.getArticleById(widget.articleId);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _article = result['data'];
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error']?.toString() ?? 'Failed to load article';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _article?['title'] ?? widget.title ?? 'Article',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadArticle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF36599F),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _article == null
                  ? const Center(child: Text('Article not found'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_article!['imageUrl'] != null)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                image: _article!['imageUrl'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(_article!['imageUrl']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _article!['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF36599F),
                                  ),
                                ),
                                if (_article!['description'] != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _article!['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (_article!['readTimeMinutes'] != null)
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_article!['readTimeMinutes']} min read',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_article!['author'] != null) ...[
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            _article!['author'] ?? '',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 24),
                                Text(
                                  _article!['content'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.8,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (_article!['tags'] != null &&
                                    _article!['tags'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: (_article!['tags']
                                            .toString()
                                            .split(',') as List)
                                        .map((tag) => Chip(
                                              label: Text(
                                                tag.trim(),
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              backgroundColor: const Color(0xFF36599F)
                                                  .withOpacity(0.1),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}

