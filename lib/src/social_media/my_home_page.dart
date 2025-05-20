import 'package:flutter/material.dart';
import 'social_text_editing_controller.dart';
import 'social_api_service.dart';
import 'social_text_field.dart';
import 'enhanced_social_text_field.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SocialApiService _apiService = SocialApiService();
  String _currentText = '';
  List<String> _posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                          radius: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    EnhancedSocialTextField(
                      hintText: "What's on your mind?",
                      maxLines: 5,
                      minLines: 3,
                      hashtagStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      mentionStyle: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (text) {
                        setState(() {
                          _currentText = text;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _currentText.trim().isEmpty ? null : _addPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Post'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _posts.isEmpty
                ? Center(
                    child: Text(
                      'No posts yet. Try adding some with hashtags and mentions!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _buildPostCard(_posts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(String text) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/40'),
                  radius: 20,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Just now',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildFormattedText(text),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.thumb_up_outlined),
                  label: Text('Like'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.comment_outlined),
                  label: Text('Comment'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.share_outlined),
                  label: Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    // Simple regex to detect hashtags and mentions
    final hashtagRegExp = RegExp(r'#[a-zA-Z0-9_]+');
    final mentionRegExp = RegExp(r'@[a-zA-Z0-9_\.]+');
    
    // Split the text by hashtags and mentions
    final spans = <TextSpan>[];
    int lastIndex = 0;
    
    // Combine hashtag and mention patterns
    final pattern = RegExp('$hashtagRegExp|$mentionRegExp');
    
    for (final match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
        ));
      }
      
      // Add the match with appropriate styling
      final matchText = match.group(0)!;
      if (matchText.startsWith('#')) {
        spans.add(TextSpan(
          text: matchText,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (matchText.startsWith('@')) {
        spans.add(TextSpan(
          text: matchText,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
      ));
    }
    
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        children: spans,
      ),
    );
  }

  void _addPost() {
    if (_currentText.trim().isNotEmpty) {
      setState(() {
        _posts.insert(0, _currentText);
        _currentText = '';
      });
    }
  }
}
