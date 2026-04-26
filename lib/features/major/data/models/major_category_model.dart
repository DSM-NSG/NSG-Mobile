class MajorCategory {
  final String id;
  final String name;

  const MajorCategory({required this.id, required this.name});

  factory MajorCategory.fromJson(Map<String, dynamic> json) => MajorCategory(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
      );
}
