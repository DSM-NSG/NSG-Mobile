import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsg_mobile/features/share/data/dummy/post_detail_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';

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
    final detail = registry[postId] ?? getPostDetail(postId);
    return PostDetailState(
      isLiked: false,
      likeCount: detail.likes,
      comments: List.from(detail.commentList),
    );
  }

  void toggleLike() {
    state = state.copyWith(
      isLiked: !state.isLiked,
      likeCount: state.likeCount + (state.isLiked ? -1 : 1),
    );
  }

  void addComment(Comment comment) {
    state = state.copyWith(comments: [...state.comments, comment]);
  }
}

final postDetailProvider =
    NotifierProvider.family<PostDetailNotifier, PostDetailState, String>(
      PostDetailNotifier.new,
    );
