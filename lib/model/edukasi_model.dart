class VideoModel {
  final String videoUrl;

  VideoModel({required this.videoUrl});

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(videoUrl: map.keys.first);
  }

  Map<String, dynamic> toMap() {
    return {
      videoUrl: videoUrl,
    };
  }
}
