class ForumSection {
  final String title;
  final String url;
  final List<ForumSubsection> subsections;

  ForumSection(
      {required this.title, required this.subsections, required this.url});
}

class ForumSubsection {
  final String title;
  final String description;
  final String url;

  ForumSubsection(
      {required this.title, required this.description, required this.url});
}
