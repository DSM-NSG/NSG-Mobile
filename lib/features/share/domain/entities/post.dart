class Post {
  final String id;
  final String title;
  final String content;
  final String category;
  final int likes;
  final int comments;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.likes,
    required this.comments,
  });
}
