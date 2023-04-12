import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:phpbb_flutter/forum.dart';
import 'package:phpbb_flutter/forum_section.dart';
import 'package:phpbb_flutter/topic_view.dart';

void fillSubSections(List<Element> forums, List<ForumSubsection> subsections) {
  for (final forum in forums) {
    final forumTitle = forum.querySelector("a.forumtitle");
    if (forumTitle == null) {
      continue;
    }

    subsections.add(ForumSubsection(
        title: forumTitle.text,
        description: getDescription(forum),
        url: forumTitle.attributes['href'] ?? ""));
  }
}

Future<List<ForumSection>> parseHomePage(String body) async {
  List<ForumSection> sections = List.empty(growable: true);
  final document = parser.parse(body);
  final elements = document.querySelectorAll('div.forabg > div.inner');

  for (final section in elements) {
    // Section
    final element = section.querySelector(
        "ul.topiclist > li.header > dl.row-item > dt > div.list-inner > a");

    if (element == null) {
      continue;
    }

    final title = element.text;
    final link = element.attributes['href'] ?? '';

    // Forums
    final forums = section.querySelectorAll(
        "ul.topiclist.forums > li.row > dl.row-item > dt > div.list-inner");

    List<ForumSubsection> subsections = [];
    fillSubSections(forums, subsections);

    sections
        .add(ForumSection(title: title, subsections: subsections, url: link));
  }

  return sections;
}

Forum parseForum(String body) {
  final document = parser.parse(body);
  final sectionsContainer = document.querySelector("div.forabg");
  final topicsContainer = document.querySelector("div.forumbg");
  final List<TopicReference> topics = [];
  final List<ForumSubsection> subsections = [];

  if (sectionsContainer != null) {
    // Has sub-sections
    final sectionRows = sectionsContainer.querySelectorAll(
        "div.inner > ul.topiclist.forums > li.row > dl > dt > div.list-inner");
    fillSubSections(sectionRows, subsections);
  }

  if (topicsContainer == null) {
    throw Exception("Unable to find topics");
  }

  final topicsElements =
      topicsContainer.querySelectorAll("ul.topiclist.topics > li > dl");
  for (var topic in topicsElements) {
    final topicTitleEl = topic.querySelector("a.topictitle");
    if (topicTitleEl == null) {
      continue;
    }
    final topicPosterEl = topic.querySelector("div.topic-poster > a.username");
    if (topicPosterEl == null) {
      continue;
    }

    final topicPostedOnEl = topic.querySelector("div.topic-poster > time");
    if (topicPostedOnEl == null) {
      continue;
    }

    final topicRepliesEl = topic.querySelector("dd.posts");
    if (topicRepliesEl == null) {
      continue;
    }

    final repliesCount = topicRepliesEl.nodes[0].text;
    final topicReplies = int.parse(repliesCount ?? "0");

    final topicPostedOn =
        DateTime.parse(topicPostedOnEl.attributes['datetime'] ?? "");

    final topicTitle = topicTitleEl.text;
    final topicUrl = topicTitleEl.attributes['href'] ?? "";
    final topicAuthor = topicPosterEl.text;

    topics.add(TopicReference(
        topicTitle, topicAuthor, topicPostedOn, topicReplies, topicUrl));
  }

  return Forum(subsections, topics);
}

Topic parseTopic(String body) {
  final List<Post> posts = [];
  final document = parser.parse(body);
  final postsElements =
      document.getElementById("page-body")!.querySelectorAll("div.post");

  for (var postEl in postsElements) {
    final postSubjEl = postEl.querySelector("div.postbody h3 a");
    if (postSubjEl == null) {
      continue;
    }
    final postSubj = postSubjEl.text;
    final postContentEl = postEl.querySelector("div.postbody div.content");

    final postAuthorEl = postEl.querySelector("p.author a.username");
    var postAuthor = "";
    if (postAuthorEl != null) {
      postAuthor = postAuthorEl.text;
    }

    final postCreatedAtEl = postEl.querySelector("p.author > time[datetime]");
    final postCreatedAt =
        DateTime.parse(postCreatedAtEl!.attributes["datetime"] ?? "");

    posts.add(
      Post(
          subject: postSubj,
          author: Author(name: postAuthor),
          createdAt: postCreatedAt,
          content: postContentEl!.innerHtml),
    );
  }

  return Topic(posts: posts, title: "test");
}

Future<List<ForumSection>> loadPage(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return parseHomePage(response.body);
  } else {
    throw Exception('Failed to load HTML');
  }
}

Future<Forum> loadForum(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return parseForum(response.body);
  } else {
    throw Exception('Failed to load page');
  }
}

Future<Topic> loadTopic(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return parseTopic(response.body);
  } else {
    throw Exception('Failed to load page');
  }
}

String getDescription(Element forumTitle) {
  for (var element in forumTitle.nodes) {
    if (element.nodeType == Node.TEXT_NODE) {
      var text = element.text ?? "";
      text = text.trim();
      if (text != "" && text != ",") {
        return text;
      }
    }
  }

  return "";
}
