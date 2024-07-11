class Post {
  final String user;
  final String title;
  final String preview;

  Post({
    required this.user,       
    required this.title,
    required this.preview,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      user: json['user'],
      title: json['title'],
      preview: json['preview'],
    );
  }
}