import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/core/network/dio.dart';
import 'package:nsg_mobile/features/auth/data/auth_service.dart';
import 'package:nsg_mobile/features/mypage/data/models/user_model.dart';
import 'package:nsg_mobile/features/mypage/data/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioClientProvider));
});

final mypageProvider = FutureProvider<UserModel>((ref) async {
  log('마이페이지 사용자 정보 조회 시작', name: 'Mypage');
  try {
    final savedUser = await AuthService.getUser();
    final user = await ref.watch(userServiceProvider).getMe();
    final serverName = user.name?.trim();
    final resolvedName =
        serverName != null &&
            serverName.isNotEmpty &&
            serverName != user.userId &&
            serverName != savedUser?.accountId
        ? serverName
        : savedUser?.name.trim();
    final merged = user.copyWith(
      name: resolvedName,
      grade: savedUser?.grade ?? user.grade,
      classNum: savedUser?.classNum ?? user.classNum,
      num: savedUser?.num ?? user.num,
    );
    log(
      '마이페이지 사용자 정보 조회 성공: ${merged.displayName} ${merged.studentNumberLabel}',
      name: 'Mypage',
    );
    return merged;
  } catch (e) {
    log('마이페이지 사용자 정보 조회 실패: $e', name: 'Mypage');
    rethrow;
  }
});
