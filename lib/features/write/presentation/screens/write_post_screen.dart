import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/core/components/category_filter.dart';
import 'package:nsg_mobile/core/components/elevated_button.dart';
import 'package:nsg_mobile/core/components/nsg_dialog.dart';
import 'package:nsg_mobile/core/components/nsg_input_field.dart';
import 'package:nsg_mobile/core/components/page_header.dart';
import 'package:nsg_mobile/core/components/photo_upload_button.dart';
import 'package:nsg_mobile/features/share/data/dummy/post_detail_dummy_data.dart';
import 'package:nsg_mobile/features/share/domain/entities/post.dart';
import 'package:nsg_mobile/features/share/domain/entities/post_detail.dart';
import 'package:nsg_mobile/features/share/presentation/providers/post_detail_provider.dart';
import 'package:nsg_mobile/features/share/presentation/providers/share_provider.dart';
import 'package:nsg_mobile/features/write/data/services/naver_local_search_service.dart';
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
  String? _selectedCategory;
  LocationResult? _locationResult;
  final List<XFile> _images = [];

  bool get _isFormValid =>
      _titleController.text.isNotEmpty &&
      _contentController.text.isNotEmpty &&
      (widget.type != 'place' || _selectedCategory != null);

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() => setState(() {}));
    _contentController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null && mounted) {
        setState(() => _images.add(picked));
      }
    } catch (e) {
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
        _locationController.text = result.address;
      });
    }
  }

  String get _categoryFromType => switch (widget.type) {
    'dormitory' => '기숙사',
    'school' => '대마고',
    _ => '기타',
  };

  Future<void> _onShare() async {
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
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final category = widget.type == 'place' ? '장소' : _categoryFromType;

    double? lat;
    double? lng;
    if (widget.type == 'place') {
      if (_locationResult?.latitude != null &&
          _locationResult?.longitude != null) {
        lat = _locationResult!.latitude;
        lng = _locationResult!.longitude;
      } else {
        // 대덕대학교 근처 임의 좌표 (반경 ~300m)
        final rng = Random();
        lat = 36.3807 + (rng.nextDouble() - 0.5) * 0.006;
        lng = 127.3862 + (rng.nextDouble() - 0.5) * 0.006;
      }
    }

    final newPost = Post(
      id: newId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: category,
      likes: 0,
      comments: 0,
      locationName: widget.type == 'place'
          ? (_locationResult?.name ?? _titleController.text.trim())
          : null,
      locationAddress: widget.type == 'place'
          ? (_locationResult?.address ?? '')
          : null,
      latitude: lat,
      longitude: lng,
      subCategory: widget.type == 'place' ? _selectedCategory : null,
    );

    final newDetail = PostDetail(
      id: newId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: category,
      authorName: isAnonymous ? '익명' : currentUserName,
      generation: isAnonymous ? null : currentUserGeneration,
      isOwn: true,
      likes: 0,
      locationName: newPost.locationName,
      locationAddress: newPost.locationAddress,
      latitude: lat,
      longitude: lng,
      subCategory: newPost.subCategory,
    );

    ref
        .read(postDetailRegistryProvider.notifier)
        .update((map) => {...map, newId: newDetail});
    ref.read(shareNewPostsProvider.notifier).addPost(newPost);

    if (mounted) {
      if (widget.type == 'place') {
        context.go('/map');
      } else {
        context.go('/share/post/$newId');
      }
    }
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
