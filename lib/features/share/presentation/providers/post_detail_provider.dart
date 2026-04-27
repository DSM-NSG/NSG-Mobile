import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

@immutable
class PostDetailState {
  final bool isLiked;
  final int likeCount;
  final List<Comment> comments;

  const PostDetailState({
    required this.isLiked,
    required this.likeCount,
    required this.comments,
  });

  PostDetailState copyWith({
    bool? isLiked,
    int? likeCount,
    List<Comment>? comments,
  }) {
    return PostDetailState(
      isLiked: isLiked ?? this.isLiked,
      likeCount: likeCount ?? this.likeCount,
      comments: comments ?? this.comments,
    );
  }
}

final postDetailRegistryProvider = StateProvider<Map<String, PostDetail>>(
  (ref) => {},
);

class PostDetailNotifier extends FamilyNotifier<PostDetailState, String> {
  @override
  PostDetailState build(String postId) {
    final registry = ref.read(postDetailRegistryProvider);
    final detail = registry[postId];
    if (detail == null) {
      log('PostDetail not found in registry: $postId', name: 'PostDetail');
      return const PostDetailState(isLiked: false, likeCount: 0, comments: []);
    }
    log('PostDetail loaded: $postId', name: 'PostDetail');
    return PostDetailState(
      isLiked: false,
      likeCount: detail.likes,
      comments: List.from(detail.commentList),
    );
  }

  void toggleLike() {
    final nextIsLiked = !state.isLiked;
    final nextLikeCount = state.likeCount + (state.isLiked ? -1 : 1);
    state = state.copyWith(isLiked: nextIsLiked, likeCount: nextLikeCount);
    _syncDetail(likes: nextLikeCount, comments: state.comments);
  }

  void addComment(Comment comment) {
    final nextComments = [...state.comments, comment];
    state = state.copyWith(comments: nextComments);
    _syncDetail(likes: state.likeCount, comments: nextComments);
  }

  void _syncDetail({required int likes, required List<Comment> comments}) {
    final registry = ref.read(postDetailRegistryProvider);
    final detail = registry[arg];
    if (detail != null) {
      ref
          .read(postDetailRegistryProvider.notifier)
          .update(
            (map) => {
              ...map,
              arg: detail.copyWith(likes: likes, commentList: comments),
            },
          );
    }

    ref
        .read(shareNewPostsProvider.notifier)
        .updatePostStats(id: arg, likes: likes, comments: comments.length);
  }
}

final postDetailProvider =
    NotifierProvider.family<PostDetailNotifier, PostDetailState, String>(
      PostDetailNotifier.new,
    );
