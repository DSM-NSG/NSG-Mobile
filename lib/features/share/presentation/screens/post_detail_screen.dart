import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/nsg_dialog.dart';
import 'package:nsg_mobile/features/mypage/presentation/providers/mypage_provider.dart';
import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';
import 'package:nsg_mobile/features/share/presentation/providers/post_detail_provider.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  PostDetail? _post;
  String? _showReplyBadgeId;
  String? _replyingToId;
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final registry = ref.read(postDetailRegistryProvider);
    _post = registry[widget.postId];
    if (_post == null) {
      log('게시글을 찾을 수 없음: postId=${widget.postId}', name: 'PostDetail');
    } else {
      log(
        '게시글 상세 진입: postId=${widget.postId}, title=${_post!.title}',
        name: 'PostDetail',
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleLike() {
    log('좋아요 토글: postId=${widget.postId}', name: 'PostDetail');
    ref.read(postDetailProvider(widget.postId).notifier).toggleLike();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final result = await NsgDialog.show(
      context,
      title: '댓글 작성',
      content:
          '댓글 작성 시 익명으로 작성이 가능합니다. 익명으로 작성 하시겠습니까?\n아니요 클릭 시 실명과 기수가 보여집니다.',
      cancelLabel: '아니요',
      confirmLabel: '네',
    );

    if (result == null || !mounted) return;

    final isAnonymous = result == true;
    final user = ref.read(mypageProvider).valueOrNull;
    final newComment = Comment(
      id: _uuid.v4(),
      authorName: isAnonymous ? '익명' : (user?.displayName ?? '-'),
      generation: isAnonymous ? null : user?.cohortLabel,
      content: text,
      parentId: _replyingToId,
    );

    log(
      '댓글 작성: postId=${widget.postId}, anonymous=$isAnonymous',
      name: 'PostDetail',
    );
    ref.read(postDetailProvider(widget.postId).notifier).addComment(newComment);

    setState(() {
      _showReplyBadgeId = null;
      _replyingToId = null;
      _commentController.clear();
    });
    _focusNode.unfocus();
  }

  Future<void> _deletePost() async {
    final result = await NsgDialog.show(
      context,
      title: '게시글 삭제',
      content: '해당 글을 삭제할 수 있습니다.\n단, 삭제 시 되돌릴 수 없습니다.\n그래도 게시글을 삭제 하시겠습니까?',
      cancelLabel: '취소',
      confirmLabel: '삭제',
    );

    if (result == true && mounted) {
      final id = widget.postId;
      log('게시글 삭제: postId=$id', name: 'PostDetail');
      ref.read(shareNewPostsProvider.notifier).removePost(id);
      ref.read(shareDeletedIdsProvider.notifier).update((s) => {...s, id});
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null) {
      return Scaffold(
        backgroundColor: NsgColor.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Text(
                    '게시글을 찾을 수 없습니다.',
                    style: NsgTextStyle.body2.copyWith(
                      color: NsgColor.black400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final detailState = ref.watch(postDetailProvider(widget.postId));
    final topLevel = detailState.comments
        .where((c) => c.parentId == null)
        .toList();

    return Scaffold(
      backgroundColor: NsgColor.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showReplyBadgeId = null;
                    _replyingToId = null;
                  });
                  _focusNode.unfocus();
                },
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      _buildPostContent(detailState),
                      const SizedBox(height: 14),
                      const Divider(color: NsgColor.black100, height: 1),
                      const SizedBox(height: 14),
                      ...topLevel.expand((c) {
                        final replies = detailState.comments
                            .where((r) => r.parentId == c.id)
                            .toList();
                        return [
                          _CommentRow(
                            comment: c,
                            showBadge: _showReplyBadgeId == c.id,
                            onMoreTap: () {
                              setState(() {
                                _showReplyBadgeId = _showReplyBadgeId == c.id
                                    ? null
                                    : c.id;
                                if (_showReplyBadgeId != c.id) {
                                  _replyingToId = null;
                                }
                              });
                            },
                            onBadgeTap: () {
                              setState(() => _replyingToId = c.id);
                              _focusNode.requestFocus();
                            },
                          ),
                          ...replies.map((r) => _ReplyRow(comment: r)),
                          const SizedBox(height: 14),
                        ];
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildCommentInput(detailState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              behavior: HitTestBehavior.opaque,
              child: const Icon(Symbols.chevron_left, color: NsgColor.black800),
            ),
          ),
          if (_post?.isOwn == true)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _deletePost,
                behavior: HitTestBehavior.opaque,
                child: const Icon(
                  Symbols.delete,
                  color: NsgColor.danger,
                  fill: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostDetailState detailState) {
    final post = _post!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Avatar(size: 40),
            const SizedBox(width: 10),
            Text(
              post.generation != null
                  ? '${post.authorName} ${post.generation}'
                  : post.authorName,
              style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          post.title,
          style: NsgTextStyle.header1.copyWith(color: NsgColor.black800),
        ),
        const SizedBox(height: 10),
        Text(
          post.content,
          style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
        ),
        if (post.allImagePaths.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: post.allImagePaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _PostImage(path: post.allImagePaths[index]),
              ),
            ),
          ),
        ],
        if (post.locationName != null &&
            post.latitude != null &&
            post.longitude != null) ...[
          const SizedBox(height: 14),
          _PlaceInfoCard(post: post),
        ],
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _toggleLike,
              child: Icon(
                Symbols.favorite,
                size: 16,
                fill: detailState.isLiked ? 1 : 0,
                color: NsgColor.orange400,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${detailState.likeCount}+',
              style: NsgTextStyle.body3.copyWith(color: NsgColor.orange400),
            ),
            const SizedBox(width: 10),
            const Icon(
              Symbols.chat_bubble,
              size: 16,
              color: NsgColor.orange400,
              fill: 1,
            ),
            const SizedBox(width: 4),
            Text(
              '${detailState.comments.length}+',
              style: NsgTextStyle.body3.copyWith(color: NsgColor.orange400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentInput(PostDetailState detailState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: NsgColor.background,
        border: Border(top: BorderSide(color: NsgColor.black100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: NsgColor.black50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _focusNode,
                style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: _replyingToId != null
                      ? '대댓글을 작성하세요.'
                      : '댓글을 작성하세요.',
                  hintStyle: NsgTextStyle.body3.copyWith(
                    color: NsgColor.black400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                cursorColor: NsgColor.orange300,
                onSubmitted: (_) => _submitComment(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _submitComment,
            child: const Icon(Symbols.send, color: NsgColor.orange400, fill: 1),
          ),
        ],
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  final String path;

  const _PostImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(path);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    return isRemote
        ? Image.network(
            path,
            width: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          )
        : Image.file(
            File(path),
            width: 220,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(),
          );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: NsgColor.black50,
      child: const Center(
        child: Icon(Symbols.image, color: NsgColor.black300, size: 28),
      ),
    );
  }
}

class _PlaceInfoCard extends StatelessWidget {
  final PostDetail post;

  const _PlaceInfoCard({required this.post});

  Future<void> _openNaverRoute(BuildContext context) async {
    final destinationName = Uri.encodeComponent(
      post.locationName ?? post.title,
    );
    final appUri = Uri.parse(
      'nmap://route/public?dlat=${post.latitude}&dlng=${post.longitude}&dname=$destinationName&appname=com.example.nsg_mobile',
    );
    final webUri = Uri.parse(
      'https://map.naver.com/v5/search/${Uri.encodeComponent(post.locationName ?? post.title)}',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('네이버 지도를 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.locationName ?? '',
            style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
          ),
          if ((post.locationAddress ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              post.locationAddress!,
              style: NsgTextStyle.body4.copyWith(color: NsgColor.black400),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _openNaverRoute(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: NsgColor.orange400,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '길찾기',
                  style: NsgTextStyle.body4.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;

  const _Avatar({this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: NsgColor.orange400,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  final Comment comment;
  final bool showBadge;
  final VoidCallback onMoreTap;
  final VoidCallback onBadgeTap;

  const _CommentRow({
    required this.comment,
    required this.showBadge,
    required this.onMoreTap,
    required this.onBadgeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Avatar(size: 32),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.generation != null
                        ? '${comment.authorName} ${comment.generation}'
                        : comment.authorName,
                    style: NsgTextStyle.body3.copyWith(
                      color: NsgColor.black800,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onMoreTap,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Symbols.more_vert,
                        size: 16,
                        color: NsgColor.black400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      comment.content,
                      style: NsgTextStyle.body3.copyWith(
                        color: NsgColor.black800,
                      ),
                    ),
                  ),
                  if (showBadge) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onBadgeTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NsgColor.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: NsgColor.orange400,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '대댓글 달기',
                          style: NsgTextStyle.body4.copyWith(
                            color: NsgColor.black800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyRow extends StatelessWidget {
  final Comment comment;

  const _ReplyRow({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '↳',
            style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
          ),
          const SizedBox(width: 6),
          const _Avatar(size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.generation != null
                      ? '${comment.authorName} ${comment.generation}'
                      : comment.authorName,
                  style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
