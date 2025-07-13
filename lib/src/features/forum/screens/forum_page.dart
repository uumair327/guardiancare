import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/forum/controllers/forum_controller.dart';
import 'package:guardiancare/src/features/forum/models/forum.dart';
import 'package:guardiancare/src/features/forum/widgets/forum_widget.dart';

class ForumPage extends StatelessWidget {
  final ForumController _controller = ForumController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forums'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Parents'),
            Tab(text: 'Children'),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildList(ForumCategory.parent),
            _buildList(ForumCategory.children),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ForumCategory cat) {
    return StreamBuilder<List<Forum>>(
      stream: _controller.getForums(cat),
      builder: (c, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        if (list.isEmpty) return const Center(child: Text('No topics.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (ctx, i) => ForumWidget(forum: list[i]),
        );
      },
    );
}
}