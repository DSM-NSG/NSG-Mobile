import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/nsg_dialog.dart';
import 'package:nsg_mobile/features/share/data/dummy/post_detail_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/comment.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';
import 'package:nsg_mobile/features/share/presentation/providers/post_detail_provider.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late PostDetail _post;
  String? _replyingToId;
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  int _idCounter = 1000;

  @override
  void initState() {
    super.initState();
    final registry = ref.read(postDetailRegistryProvider);
    _post = registry[widget.postId] ?? getPostDetail(widget.postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleLike() {
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
    final newComment = Comment(
      id: 'new_${_idCounter++}',
      authorName: isAnonymous ? '익명' : currentUserName,
      generation: isAnonymous ? null : currentUserGeneration,
      content: text,
      parentId: _replyingToId,
    );

    ref.read(postDetailProvider(widget.postId).notifier).addComment(newComment);

    setState(() {
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
      ref.read(shareNewPostsProvider.notifier).removePost(id);
      ref.read(shareDeletedIdsProvider.notifier).update((s) => {...s, id});
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  if (_replyingToId != null) {
                    setState(() => _replyingToId = null);
                  }
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
                            isReplyTarget: _replyingToId == c.id,
                            onReplyTap: () {
                              setState(() {
                                _replyingToId = _replyingToId == c.id
                                    ? null
                                    : c.id;
                              });
                            },
                            onReplyConfirm: () => _focusNode.requestFocus(),
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
          if (_post.isOwn)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _Avatar(size: 40),
            const SizedBox(width: 10),
            Text(
              _post.generation != null
                  ? '${_post.authorName} ${_post.generation}'
                  : _post.authorName,
              style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _post.title,
          style: NsgTextStyle.header1.copyWith(color: NsgColor.black800),
        ),
        const SizedBox(height: 10),
        Text(
          _post.content,
          style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
        ),
        if (_post.imagePath != null) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              _post.imagePath!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
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
  final bool isReplyTarget;
  final VoidCallback onReplyTap;
  final VoidCallback? onReplyConfirm;

  const _CommentRow({
    required this.comment,
    required this.isReplyTarget,
    required this.onReplyTap,
    this.onReplyConfirm,
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
                    onTap: onReplyTap,
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
                  if (isReplyTarget) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onReplyConfirm,
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
