import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/core/network/dio.dart';
import 'package:nsg_mobile/features/auth/data/auth_service.dart';
import 'package:nsg_mobile/features/auth/domain/models/user_model.dart' as auth;
import 'package:nsg_mobile/features/mypage/data/models/user_model.dart';
import 'package:nsg_mobile/features/mypage/data/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioClientProvider));
});

final mypageProvider = FutureProvider<UserModel>((ref) async {
  log('마이페이지 사용자 정보 조회 시작', name: 'Mypage');
  final savedUser = await AuthService.getUser();
  try {
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
      cohort: user.cohort > 0 ? user.cohort : (savedUser?.cohort ?? 0),
    );
    log(
      '마이페이지 사용자 정보 조회 성공: ${merged.displayName} '
      '| /me 기수=${user.cohort} | 캐시 기수=${savedUser?.cohort} | 최종=${merged.cohort}',
      name: 'Mypage',
    );
    await AuthService.cacheUser(
      auth.UserModel(
        id: savedUser?.id ?? '',
        accountId: merged.userId,
        name: merged.displayName,
        grade: merged.grade,
        classNum: merged.classNum,
        num: merged.num,
        cohort: merged.cohort,
      ),
    );
    return merged;
  } catch (e) {
    log('마이페이지 사용자 정보 조회 실패: $e', name: 'Mypage');
    if (savedUser != null) {
      return UserModel(
        userId: savedUser.accountId,
        name: savedUser.name,
        grade: savedUser.grade,
        classNum: savedUser.classNum,
        num: savedUser.num,
        cohort: savedUser.cohort ?? 0,
      );
    }
    rethrow;
  }
});
