class Video {
  final String thumbnail;
  final String title;
  final String videoUrl;

  Video({required this.thumbnail, required this.title, required this.videoUrl});

  factory Video.fromDocumentSnapshot(Map<String, dynamic> doc) {
    return Video(
      thumbnail: doc['thumbnail'],
      title: doc['title'],
      videoUrl: doc['video'],
    );
  }
}
