import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:phpbb_flutter/parse.dart';

class Topic {
  final String title;
  final List<Post> posts;

  Topic({required this.title, required this.posts});
}

class Author {
  final String name;
  Author({required this.name});
}

class Post {
  final String subject;
  final Author author;
  final String content;
  final DateTime createdAt;

  Post(
      {required this.subject,
      required this.author,
      required this.content,
      required this.createdAt});
}

class TopicView extends StatefulWidget {
  final String title;
  final String url;

  const TopicView({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  _TopicViewState createState() => _TopicViewState();
}

class _TopicViewState extends State<TopicView> {
  Topic? _topic;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    final topic = await loadTopic(widget.url);
    setState(() {
      _topic = topic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _topic == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _topic!.posts.length,
              itemBuilder: (context, index) {
                final post = _topic!.posts[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.author.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post.createdAt.toString(), // format as desired
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Html(
                        data: post.content,
                        customRenders: {
                          (context) =>
                              context.tree.element?.attributes["src"] != null &&
                              context.tree.element!.attributes["src"]!
                                  .startsWith("./"): networkImageRender(
                              mapUrl: (url) => Uri.parse(widget.url)
                                  .resolve(url!)
                                  .toString()),
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
