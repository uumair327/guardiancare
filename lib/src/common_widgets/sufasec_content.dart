import 'package:flutter/material.dart';

class CustomContentPage extends StatelessWidget {
  final Map<String, dynamic> content;

  const CustomContentPage({super.key, required this.content});

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
            _buildDescriptionSection(),
            if (stats.isNotEmpty) _buildStatsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Text(
      content['description']?.toString() ?? '',
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatsGrid() {
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
            _buildStatCard('Children Reached', stats['children']),
          if (stats.containsKey('families'))
            _buildStatCard('Families Supported', stats['families']),
          if (stats.containsKey('districts'))
            _buildStatCard('Districts Covered', stats['districts']),
          if (stats.containsKey('states'))
            _buildStatCard('States Operating', stats['states']),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
