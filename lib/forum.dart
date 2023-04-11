import 'package:phpbb_flutter/forum_section.dart';

class Forum {
  final List<ForumSubsection> subsections;
  final List<TopicReference> topics;

  Forum(this.subsections, this.topics);
}

class TopicReference {
  final String title;
  final String author;
  final DateTime postedOn;
  final int replies;
  final String url;
  TopicReference(
      this.title, this.author, this.postedOn, this.replies, this.url);
}
