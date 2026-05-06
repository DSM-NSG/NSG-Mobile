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
      grade: json['grade'] is int ? json['grade'] as int : int.tryParse('${json['grade']}') ?? 0,
      classNum: json['class_num'] is int ? json['class_num'] as int : int.tryParse('${json['class_num']}') ?? 0,
      num: json['num'] is int ? json['num'] as int : int.tryParse('${json['num']}') ?? 0,
      cohort: json['cohort'] is int ? json['cohort'] as int : int.tryParse('${json['cohort']}') ?? 0,
    );
  }

  String get displayName => name != null && name!.isNotEmpty ? name! : userId;
  String get cohortLabel => '$cohort기';
  String get detailLabel => '$grade학년 $classNum반 $num번';
  String get studentNumberLabel =>
      '$grade$classNum${num.toString().padLeft(2, '0')}';
  String get profileSubtitle => cohort > 0 ? cohortLabel : studentNumberLabel;
}

const _sentinel = Object();
