class Resource {
  final String title;
  final String url;
  final String type; // 'pdf', 'link', etc.
  Resource({
    required this.title,
    required this.url,
    required this.type,
  });

  factory Resource.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return Resource(
      title: doc['title'] ?? 'Untitled',
      url: doc['url'],
      type: doc['type'],
    );
  }
}
