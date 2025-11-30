import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'forum_post_screen.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({Key? key}) : super(key: key);

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Community Forum', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(24),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Discuss local safetys', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Popular'),
                Tab(text: 'Recent'),
                Tab(text: 'Following'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForumList(context),
                Center(child: Text('Recent posts coming soon...')),
                Center(child: Text('Following posts coming soon...')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePostScreen(),
              ),
            );
          },
          child: const Text('Create New Post', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Color(0xFF36599F),
          ),
        ),
      ),
    );
  }

  Widget _buildForumList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildForumCard(
          context: context,
          initials: 'JD',
          name: 'Jane Doe',
          location: 'Oak Street',
          time: '2 hrs ago',
          title: 'Best home security cameras 2023?',
          content: 'Looking for recommendations for outdoor security cameras with good night vision and motion detection...',
          comments: 12,
          helpful: 24,
        ),
        _buildForumCard(
          context: context,
          initials: 'MC',
          name: 'Mike Chen',
          location: 'Downtown',
          time: 'Yesterday',
          title: 'Neighborhood patrol tips',
          content: "Sharing what we've learned from 6 months of organizing patrols in our area - best practices, schedules, and safety precautions...",
          comments: 8,
          helpful: 42,
        ),
        _buildForumCard(
          context: context,
          initials: 'PD',
          name: 'Police Dept',
          location: 'Official',
          time: '3 days ago',
          title: 'Holiday Safety Advisory',
          content: 'Important safety tips for the holiday season - package theft prevention, travel safety, and emergency contacts...',
          comments: 5,
          helpful: 36,
        ),
      ],
    );
  }

  Widget _buildForumCard({
    required String initials,
    required String name,
    required String location,
    required String time,
    required String title,
    required String content,
    required int comments,
    required int helpful,
    required BuildContext context,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumPostScreen(
                postData: {
                  'initials': initials,
                  'name': name,
                  'location': location,
                  'time': time,
                  'title': title,
                  'content': content,
                  'comments': comments,
                  'helpful': helpful,
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(content, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.comment, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$comments Comments', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 16),
                  const Icon(Icons.emoji_people, size: 18, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('$helpful Helpful', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}