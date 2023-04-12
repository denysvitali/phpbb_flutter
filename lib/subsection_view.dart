import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phpbb_flutter/parse.dart';
import 'package:phpbb_flutter/topic_view.dart';

import 'forum.dart';
import 'forum_section.dart';

class SubsectionView extends StatefulWidget {
  final ForumSubsection subsection;

  const SubsectionView({Key? key, required this.subsection}) : super(key: key);

  @override
  _SubsectionViewState createState() => _SubsectionViewState();
}

class _SubsectionViewState extends State<SubsectionView> {
  Forum? _forum;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    var forum = await loadForum(widget.subsection.url);
    setState(() {
      _forum = forum;
    });
  }

  void _navigateToTopic(TopicReference topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicView(title: topic.title, url: topic.url),
      ),
    );
  }

  void _navigateToSubSection(ForumSubsection subsection) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubsectionView(subsection: subsection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat format = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subsection.title),
      ),
      body: _forum == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              separatorBuilder: (context, index) => const Divider(),
              itemCount: _forum!.topics.length + 1,
              itemBuilder: (context, topicIndex) {
                if (topicIndex == 0) {
                  return ExpansionTile(
                    title: const Text("Forums"),
                    children: _forum!.subsections
                        .map((subsection) => ListTile(
                              title: Text(subsection.title),
                              subtitle: Text(subsection.description),
                              onTap: () => _navigateToSubSection(subsection),
                            ))
                        .toList(),
                  );
                }
                topicIndex--;
                final topic = _forum!.topics[topicIndex];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: InkWell(
                      onTap: () => {_navigateToTopic(topic)},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'by ${topic.author} • ${format.format(topic.postedOn)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      )),
                );
              }),
    );
  }
}
