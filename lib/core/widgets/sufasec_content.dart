import 'package:flutter/material.dart';
import 'package:guardiancare/core/core.dart';

class CustomContentPage extends StatelessWidget {

  const CustomContentPage({super.key, required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final stats =
        content['stats'] is Map ? content['stats'] as Map<String, dynamic> : {};

    return Scaffold(
      appBar: AppBar(
        title: Text(content['title']?.toString() ?? 'Our Program'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDescriptionSection(context),
            if (stats.isNotEmpty) _buildStatsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Text(
      content['description']?.toString() ?? '',
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = content['stats'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          if (stats.containsKey('children'))
            _buildStatCard(context, 'Children Reached', stats['children']),
          if (stats.containsKey('families'))
            _buildStatCard(context, 'Families Supported', stats['families']),
          if (stats.containsKey('districts'))
            _buildStatCard(context, 'Districts Covered', stats['districts']),
          if (stats.containsKey('states'))
            _buildStatCard(context, 'States Operating', stats['states']),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.colors.textSecondary.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
