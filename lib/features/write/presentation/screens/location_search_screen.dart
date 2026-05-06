import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/write/data/services/naver_local_search_service.dart';

const _kFallbackCenter = LatLng(36.3807, 127.3862);
const _kSearchZoom = 15.5;

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _mapController = MapController();

  List<NaverLocalItem> _results = [];
  NaverLocalItem? _selectedItem;
  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _myLocation;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final current = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final latLng = LatLng(current.latitude, current.longitude);
      _mapController.move(latLng, _kSearchZoom);
      setState(() => _myLocation = latLng);
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _selectedItem = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await NaverLocalSearchService.search(
        query,
        nearLat: _myLocation?.latitude,
        nearLon: _myLocation?.longitude,
      );
      if (mounted) {
        if (results.isNotEmpty) {
          _mapController.move(
            LatLng(results.first.latitude, results.first.longitude),
            _kSearchZoom,
          );
        }
        setState(() {
          _results = results;
          _selectedItem = results.isNotEmpty ? results.first : null;
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

  void _selectItem(NaverLocalItem item) {
    _mapController.move(LatLng(item.latitude, item.longitude), _kSearchZoom);
    setState(() => _selectedItem = item);
  }

  void _submitSelection() {
    final item = _selectedItem;
    if (item == null) return;
    final result = LocationResult.fromNaverItem(item);
    Navigator.of(context).pop(result);
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
              onChanged: _onSearchChanged,
              onSubmitted: _search,
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
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _myLocation ?? _kFallbackCenter,
                  initialZoom: _kSearchZoom,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.nsg_mobile',
                  ),
                  if (_myLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _myLocation!,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: _results
                        .map(
                          (item) => Marker(
                            point: LatLng(item.latitude, item.longitude),
                            width: 42,
                            height: 42,
                            child: GestureDetector(
                              onTap: () => _selectItem(item),
                              child: Icon(
                                Symbols.location_on,
                                size: 40,
                                fill: 1,
                                color: identical(item, _selectedItem)
                                    ? NsgColor.orange400
                                    : NsgColor.black400,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: NsgColor.orange400),
                ),
              if (_errorMessage != null)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: _NoticeCard(message: _errorMessage!),
                ),
              if (!_isLoading &&
                  _errorMessage == null &&
                  _results.isEmpty &&
                  _searchController.text.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: const _NoticeCard(message: '검색 결과가 없습니다.'),
                ),
            ],
          ),
        ),
        Container(
          height: 280,
          decoration: const BoxDecoration(
            color: NsgColor.background,
            border: Border(top: BorderSide(color: NsgColor.black100)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: NsgColor.black100),
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    final isSelected = identical(item, _selectedItem);
                    return _ResultTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => _selectItem(item),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedItem != null ? _submitSelection : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: NsgColor.orange400,
                      disabledBackgroundColor: NsgColor.black100,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      '선택한 장소 추가',
                      style: NsgTextStyle.body2.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBack;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
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
            child: const Icon(
              Symbols.arrow_back_ios,
              size: 20,
              color: NsgColor.black800,
            ),
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
                onSubmitted: onSubmitted,
                style: NsgTextStyle.body3.copyWith(color: NsgColor.black800),
                cursorColor: NsgColor.orange300,
                decoration: InputDecoration(
                  hintText: '장소명 또는 주소를 입력하세요.',
                  hintStyle: NsgTextStyle.body3.copyWith(
                    color: NsgColor.black400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: NsgColor.black400,
                    size: 20,
                  ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _ResultTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

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
                Icon(
                  Symbols.location_on,
                  size: 18,
                  color: isSelected ? NsgColor.orange400 : NsgColor.black400,
                  fill: 1,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.plainTitle,
                    style: NsgTextStyle.body2.copyWith(
                      color: NsgColor.black800,
                    ),
                  ),
                ),
                if (item.category.isNotEmpty)
                  Text(
                    item.category,
                    style: NsgTextStyle.body4.copyWith(
                      color: NsgColor.black400,
                    ),
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
                      style: NsgTextStyle.body4.copyWith(
                        color: NsgColor.black500,
                      ),
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
                      style: NsgTextStyle.body4.copyWith(
                        color: NsgColor.black500,
                      ),
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

class _NoticeCard extends StatelessWidget {
  final String message;

  const _NoticeCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: NsgTextStyle.body3.copyWith(color: NsgColor.black500),
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
