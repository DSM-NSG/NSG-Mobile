class Comment {
  final String id;
  final String authorName;
  final String? generation;
  final String content;
  final String? parentId;

  const Comment({
    required this.id,
    required this.authorName,
    this.generation,
    required this.content,
    this.parentId,
  });
}
