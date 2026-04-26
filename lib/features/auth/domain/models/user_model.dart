class UserModel {
  final String id;
  final String accountId;
  final String name;
  final int grade;
  final int classNum;
  final int num;

  const UserModel({
    required this.id,
    required this.accountId,
    required this.name,
    required this.grade,
    required this.classNum,
    required this.num,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      name: json['name'] as String,
      grade: json['grade'] as int,
      classNum: json['class_num'] as int,
      num: json['num'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_id': accountId,
        'name': name,
        'grade': grade,
        'class_num': classNum,
        'num': num,
      };
}
