import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/write/data/services/naver_local_search_service.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<NaverLocalItem> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await NaverLocalSearchService.search(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '검색 중 오류가 발생했습니다.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _search,
              onBack: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: NsgColor.black100),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: NsgColor.orange400),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: NsgTextStyle.body3),
      );
    }

    if (_results.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: NsgTextStyle.body3.copyWith(color: NsgColor.black400),
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: NsgColor.black100),
      itemBuilder: (context, index) {
        final item = _results[index];
        return _ResultTile(
          item: item,
          onTap: () => Navigator.of(context).pop(item.displayAddress),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Symbols.arrow_back_ios,
                size: 20, color: NsgColor.black800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: NsgColor.black50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: onChanged,
                style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
                cursorColor: NsgColor.orange300,
                decoration: InputDecoration(
                  hintText: '장소명 또는 주소를 입력하세요.',
                  hintStyle:
                      NsgTextStyle.body3.copyWith(color: NsgColor.black400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: const Icon(Icons.search,
                      color: NsgColor.black400, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final NaverLocalItem item;
  final VoidCallback onTap;

  const _ResultTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.plainTitle,
                    style:
                        NsgTextStyle.body2.copyWith(color: NsgColor.black800),
                  ),
                ),
                if (item.category.isNotEmpty)
                  Text(
                    item.category,
                    style:
                        NsgTextStyle.body4.copyWith(color: NsgColor.black400),
                  ),
              ],
            ),
            if (item.roadAddress.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _AddressTag(label: '도로명'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.roadAddress,
                      style: NsgTextStyle.body4
                          .copyWith(color: NsgColor.black500),
                    ),
                  ),
                ],
              ),
            ],
            if (item.address.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  _AddressTag(label: '지  번'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.address,
                      style: NsgTextStyle.body4
                          .copyWith(color: NsgColor.black500),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddressTag extends StatelessWidget {
  final String label;

  const _AddressTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: NsgColor.black400),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: NsgTextStyle.body4.copyWith(
          color: NsgColor.black500,
          fontSize: 10,
        ),
      ),
    );
  }
}
