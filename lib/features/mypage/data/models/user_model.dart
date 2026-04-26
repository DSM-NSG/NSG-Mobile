class UserModel {
  final String userId;
  final String? name;
  final int grade;
  final int classNum;
  final int num;
  final int cohort;

  const UserModel({
    required this.userId,
    this.name,
    required this.grade,
    required this.classNum,
    required this.num,
    required this.cohort,
  });

  UserModel copyWith({
    String? userId,
    Object? name = _sentinel,
    int? grade,
    int? classNum,
    int? num,
    int? cohort,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name == _sentinel ? this.name : name as String?,
      grade: grade ?? this.grade,
      classNum: classNum ?? this.classNum,
      num: num ?? this.num,
      cohort: cohort ?? this.cohort,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      name: (json['name'] as String?)?.trim(),
      grade: json['grade'] as int,
      classNum: json['class_num'] as int,
      num: json['num'] as int,
      cohort: json['cohort'] as int,
    );
  }

  String get displayName => name != null && name!.isNotEmpty ? name! : userId;
  String get cohortLabel => '$cohort기';
  String get detailLabel => '$grade학년 $classNum반 $num번';
  String get studentNumberLabel =>
      '$grade$classNum${num.toString().padLeft(2, '0')}';
  String get profileSubtitle => studentNumberLabel;
}

const _sentinel = Object();
