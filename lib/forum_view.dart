import 'package:flutter/material.dart';
import 'package:phpbb_flutter/forum_section.dart';
import 'package:phpbb_flutter/parse.dart';
import 'package:phpbb_flutter/subsection_view.dart';

class ForumView extends StatefulWidget {
  @override
  _ForumViewState createState() => _ForumViewState();
}

class _ForumViewState extends State<ForumView> {
  List<ForumSection> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    final sections = await loadPage("https://www.forumelettrico.it/forum/");
    setState(() => _sections = sections);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: _sections.isNotEmpty
          ? ListView.builder(
              itemCount: _sections.length,
              itemBuilder: (context, sectionIndex) {
                final section = _sections[sectionIndex];

                return ExpansionTile(
                  title: Text(section.title),
                  children: section.subsections
                      .map((subsection) => ListTile(
                            title: Text(subsection.title),
                            subtitle: Text(subsection.description),
                            onTap: () => _navigateToSubSection(subsection),
                          ))
                      .toList(),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
