import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';
import 'package:nsg_mobile/core/components/elevated_button.dart';
import 'package:nsg_mobile/core/components/nsg_dialog.dart';
import 'package:nsg_mobile/core/components/nsg_input_field.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/photo_upload_button.dart';
import 'package:nsg_mobile/features/major/data/dummy/major_dummy_data.dart';
import 'package:nsg_mobile/features/mypage/presentation/providers/mypage_provider.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';
import 'package:nsg_mobile/features/share/presentation/providers/post_detail_provider.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';
import 'package:nsg_mobile/features/write/data/services/naver_local_search_service.dart';
import 'package:nsg_mobile/features/map/data/models/place_model.dart';
import 'package:nsg_mobile/features/map/data/services/place_service.dart';
import 'package:nsg_mobile/features/share/data/services/tips_service.dart';
import 'package:nsg_mobile/features/write/presentation/screens/location_search_screen.dart';

class WritePostScreen extends ConsumerStatefulWidget {
  final String type;

  const WritePostScreen({super.key, required this.type});

  @override
  ConsumerState<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends ConsumerState<WritePostScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _contentController = TextEditingController();
  final _keywordController = TextEditingController();
  final _keywordFocusNode = FocusNode();

  String? _selectedCategory;
  LocationResult? _locationResult;
  final List<XFile> _images = [];
  final List<String> _keywords = [];
  bool _keywordFocused = false;
  bool _isSubmitting = false;

  bool get _isFormValid =>
      _titleController.text.isNotEmpty &&
      _contentController.text.isNotEmpty &&
      !_isSubmitting &&
      (widget.type != 'place' ||
          (_selectedCategory != null &&
              _locationResult != null &&
              _locationResult!.latitude != null &&
              _locationResult!.longitude != null));

  List<String> get _keywordSuggestions {
    final q = _keywordController.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    final starts = majorSearchSuggestions
        .where((s) => s.toLowerCase().startsWith(q) && !_keywords.contains(s))
        .toList();
    final contains = majorSearchSuggestions
        .where(
          (s) =>
              !s.toLowerCase().startsWith(q) &&
              s.toLowerCase().contains(q) &&
              !_keywords.contains(s),
        )
        .toList();
    return [...starts, ...contains];
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
    _keywordController.addListener(() => setState(() {}));
    _keywordFocusNode.addListener(() {
      setState(() => _keywordFocused = _keywordFocusNode.hasFocus);
    });
    dev.log('작성 화면 진입: type=${widget.type}', name: 'Write');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contentController.dispose();
    _keywordController.dispose();
    _keywordFocusNode.dispose();
    super.dispose();
  }

  void _addKeyword(String keyword) {
    final k = keyword.trim();
    if (k.isEmpty || _keywords.contains(k)) return;
    setState(() {
      _keywords.add(k);
      _keywordController.clear();
    });
    dev.log('키워드 추가: $k', name: 'Write');
  }

  void _removeKeyword(String keyword) {
    setState(() => _keywords.remove(keyword));
    dev.log('키워드 제거: $keyword', name: 'Write');
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() => _images.add(picked));
        dev.log('이미지 추가: ${picked.name}', name: 'Write');
      }
    } catch (e) {
      dev.log('이미지 불러오기 실패: $e', name: 'Write');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진을 불러올 수 없습니다. 앱을 재시작 후 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _openLocationSearch() async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(builder: (_) => const LocationSearchScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        _locationResult = result;
        _locationController.text = result.name;
      });
      dev.log('장소 선택: ${result.name}', name: 'Write');
    }
  }

  String get _categoryFromType => switch (widget.type) {
    'dormitory' => '기숙사',
    'school' => '대마고',
    'major' => '전공',
    _ => '기타',
  };

  Future<void> _onShare() async {
    dev.log(
      '공유 시도: type=${widget.type}, title=${_titleController.text.trim()}',
      name: 'Write',
    );

    final result = await NsgDialog.show(
      context,
      title: '게시글 작성',
      content:
          '게시글 작성 시 익명으로 작성이 가능합니다.\n익명으로 작성 하시겠습니까?\n아니요 클릭 시 실명과 기수가 보여집니다.',
      cancelLabel: '아니요',
      confirmLabel: '네',
      barrierDismissible: true,
    );

    if (result == null || !mounted) return;

    final isAnonymous = result == true;

    if (widget.type == 'place') {
      await _onSharePlace(isAnonymous: isAnonymous);
      return;
    }

    await _onShareTip(isAnonymous: isAnonymous);
  }

  Future<void> _onSharePlace({required bool isAnonymous}) async {
    setState(() => _isSubmitting = true);
    try {
      // 1. Register the place (POST /)
      final placeModel = await PlaceService.createPlace(
        title: _locationResult!.name,
        description: _contentController.text.trim(),
        category: appCategoryToPlaceApi(_selectedCategory!),
        latitude: _locationResult!.latitude!,
        longitude: _locationResult!.longitude!,
        isAnonymous: isAnonymous,
      );
      dev.log('장소 등록 성공: id=${placeModel.id}', name: 'Write');

      // 2. Create the tip post linked to the place (POST /posts/tips/create/)
      final tipsPost = await TipsService.createPost(
        title: _titleController.text.trim(),
        body: _contentController.text.trim(),
        category: 'PLACE',
        isAnonymous: isAnonymous,
        placeId: placeModel.id,
      );
      dev.log('장소 꿀팁 작성 성공: id=${tipsPost.id}', name: 'Write');

      // Register in local registry for immediate display
      final postDetail = tipsPost.toPostDetail(isOwn: true);
      final postId = tipsPost.id;
      ref
          .read(postDetailRegistryProvider.notifier)
          .update((map) => {...map, postId: postDetail});

      final newPost = Post(
        id: postId,
        title: tipsPost.title,
        content: tipsPost.body,
        category: '장소',
        subCategory: _selectedCategory,
        locationName: placeModel.title,
        locationAddress: _locationResult!.address,
        latitude: placeModel.latitude,
        longitude: placeModel.longitude,
        likes: 0,
        comments: 0,
        board: PostBoard.share,
      );
      ref.read(shareNewPostsProvider.notifier).addPost(newPost);

      if (mounted) context.push('/share/post/$postId');
    } catch (e) {
      dev.log('장소 꿀팁 작성 실패: $e', name: 'Write');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('장소 등록 오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _onShareTip({required bool isAnonymous}) async {
    final user = ref.read(mypageProvider).valueOrNull;
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final category = switch (widget.type) {
      'major' when _keywords.isNotEmpty => _keywords.first,
      _ => _categoryFromType,
    };

    final newPost = Post(
      id: newId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: category,
      likes: 0,
      comments: 0,
      board: widget.type == 'major' ? PostBoard.major : PostBoard.share,
    );

    final newDetail = PostDetail(
      id: newId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: category,
      authorName: isAnonymous ? '익명' : (user?.displayName ?? '-'),
      generation: isAnonymous ? null : user?.studentNumberLabel,
      isOwn: true,
      likes: 0,
      imagePath: _images.isNotEmpty ? _images.first.path : null,
      imagePaths: _images.map((image) => image.path).toList(),
    );

    ref
        .read(postDetailRegistryProvider.notifier)
        .update((map) => {...map, newId: newDetail});
    ref.read(shareNewPostsProvider.notifier).addPost(newPost);

    dev.log(
      '공유 완료: postId=$newId, category=$category, anonymous=$isAnonymous',
      name: 'Write',
    );

    if (mounted) context.push('/share/post/$newId');
  }

  String get _screenTitle => switch (widget.type) {
    'place' => '장소 꿀팁 공유하기',
    'dormitory' => '기숙사 꿀팁 공유하기',
    'school' => '대마고 꿀팁 공유하기',
    'etc' => '기타 꿀팁 공유하기',
    'major' => '전공 꿀팁 공유하기',
    _ => '꿀팁 공유하기',
  };

  @override
  Widget build(BuildContext context) {
    final suggestions = _keywordSuggestions;
    final showSuggestions =
        _keywordFocused && _keywordController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              PageHeader(title: _screenTitle),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      NsgInputField(controller: _titleController, hint: '제목'),
                      const SizedBox(height: 10),
                      if (widget.type == 'place') ...[
                        NsgInputField(
                          controller: _locationController,
                          hint: '장소를 입력해주세요.',
                          readOnly: true,
                          onTap: _openLocationSearch,
                        ),
                        const SizedBox(height: 10),
                      ],
                      NsgInputField(
                        controller: _contentController,
                        hint: '내용',
                        maxLines: null,
                        minLines: 18,
                        maxLength: 1000,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 20),
                      if (widget.type == 'place')
                        CategoryFilter(
                          categories: const ['카페', 'PC방', '노래방', '맛집', '기타'],
                          selectedCategory: _selectedCategory,
                          onSelected: (v) =>
                              setState(() => _selectedCategory = v),
                        ),
                      if (widget.type == 'major') ...[
                        Text(
                          '카테고리 추가하기',
                          style: NsgTextStyle.body3.copyWith(
                            color: NsgColor.black400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _KeywordInputField(
                          keywords: _keywords,
                          controller: _keywordController,
                          focusNode: _keywordFocusNode,
                          isFocused: _keywordFocused,
                          onAdd: _addKeyword,
                          onRemove: _removeKeyword,
                        ),
                        if (showSuggestions && suggestions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _KeywordSuggestionList(
                            suggestions: suggestions,
                            query: _keywordController.text.trim(),
                            onSelect: _addKeyword,
                          ),
                        ],
                      ],
                      const SizedBox(height: 20),
                      _PhotoSection(
                        images: _images,
                        onAdd: _pickImage,
                        onRemove: (index) =>
                            setState(() => _images.removeAt(index)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: NsgElevatedButton(
                  text: '공유',
                  enabled: _isFormValid,
                  onTap: _isFormValid ? _onShare : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordInputField extends StatelessWidget {
  final List<String> keywords;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _KeywordInputField({
    required this.keywords,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
        border: isFocused
            ? Border.all(color: NsgColor.orange300, width: 1.5)
            : null,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...keywords.map(
            (k) => _KeywordChip(label: k, onRemove: () => onRemove(k)),
          ),
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
              textInputAction: TextInputAction.done,
              cursorColor: NsgColor.orange300,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) onAdd(v.trim());
              },
              decoration: InputDecoration(
                hintText: keywords.isEmpty
                    ? '키워드 작성 후 엔터를 눌러 카테고리를 추가해주세요.'
                    : null,
                hintStyle: NsgTextStyle.body3.copyWith(
                  color: NsgColor.black400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _KeywordChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: NsgColor.orange400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NsgTextStyle.body3.copyWith(color: Colors.white)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Symbols.close, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _KeywordSuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelect;

  const _KeywordSuggestionList({
    required this.suggestions,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: NsgColor.black100),
      ),
      child: Column(
        children: suggestions
            .take(5)
            .map(
              (s) => GestureDetector(
                onTap: () => onSelect(s),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildHighlightedText(s, query),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    final q = query.toLowerCase();
    if (q.isEmpty || !text.toLowerCase().startsWith(q)) {
      return Text(
        text,
        style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, q.length),
            style: NsgTextStyle.body2.copyWith(color: NsgColor.orange400),
          ),
          TextSpan(
            text: text.substring(q.length),
            style: NsgTextStyle.body2.copyWith(color: NsgColor.black800),
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotoSection({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          PhotoUploadButton(onTap: onAdd),
          ...List.generate(images.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _SelectedImage(
                file: images[index],
                onRemove: () => onRemove(index),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SelectedImage extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _SelectedImage({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(file.path),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Symbols.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }
}
