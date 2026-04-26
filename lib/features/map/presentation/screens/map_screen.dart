import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/core/components/nsg_search_bar.dart';
import 'package:nsg_mobile/core/components/recent_post_card.dart';
import 'package:nsg_mobile/features/map/presentation/providers/map_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _kFallbackCenter = LatLng(36.3807, 127.3862);
const _kInitialZoom = 15.5;

const _categoryColors =
    <String, ({Color active, Color inactiveBg, Color inactiveText})>{
      '카페': (
        active: NsgColor.cafe,
        inactiveBg: NsgColor.cafeNon,
        inactiveText: NsgColor.background,
      ),
      'PC방': (
        active: NsgColor.pc,
        inactiveBg: NsgColor.pcNon,
        inactiveText: NsgColor.background,
      ),
      '노래방': (
        active: NsgColor.sing,
        inactiveBg: NsgColor.singNon,
        inactiveText: NsgColor.background,
      ),
      '맛집': (
        active: NsgColor.eat,
        inactiveBg: NsgColor.eatNon,
        inactiveText: NsgColor.background,
      ),
      '기타': (
        active: NsgColor.etc,
        inactiveBg: NsgColor.etcNon,
        inactiveText: NsgColor.background,
      ),
    };

Color _categoryColor(String subCategory) =>
    _categoryColors[subCategory]?.active ?? NsgColor.black500;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();

  LatLng? _myLocation;
  bool _locationLoading = true;
  bool _didMoveToMyLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLocation());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() => _locationLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationLoading = false);
        return;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        _setMyLocation(
          LatLng(lastKnown.latitude, lastKnown.longitude),
          moveMap: !_didMoveToMyLocation,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      _setMyLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  void _setMyLocation(LatLng latLng, {bool moveMap = true}) {
    if (moveMap) {
      _mapController.move(latLng, _kInitialZoom);
      _didMoveToMyLocation = true;
    }
    if (!mounted) return;
    setState(() {
      _myLocation = latLng;
      _locationLoading = false;
    });
  }

  void _moveToMyLocation() {
    if (_myLocation != null) {
      _mapController.move(_myLocation!, _kInitialZoom);
    } else {
      _fetchLocation();
    }
  }

  void _onSearchTextChanged(String text) =>
      ref.read(mapProvider.notifier).onSearchTextChanged(text);

  void _onSearchFocusChanged(bool focused) =>
      ref.read(mapProvider.notifier).onSearchFocusChanged(focused);

  void _clearSearch() => ref.read(mapProvider.notifier).clearSearch();

  void _selectSuggestion(PlaceGroup place) {
    ref.read(mapProvider.notifier).clearSearch();
    _mapController.move(LatLng(place.latitude, place.longitude), _kInitialZoom);
    _showPlaceBottomSheet(place);
  }

  void _showPlaceBottomSheet(PlaceGroup place) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlaceBottomSheet(place: place, myLocation: _myLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final placeGroups = ref.watch(placeGroupsProvider);
    final suggestions = ref.watch(
      mapSearchSuggestionsProvider(mapState.searchText),
    );

    return Scaffold(
      backgroundColor: NsgColor.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              maxZoom: 18.0,
              minZoom: 2.0,
              initialCenter: _myLocation ?? _kFallbackCenter,
              initialZoom: _kInitialZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nsg_mobile',
              ),
              MarkerLayer(
                markers: placeGroups.map((g) {
                  return Marker(
                    point: LatLng(g.latitude, g.longitude),
                    width: 36,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showPlaceBottomSheet(g),
                      child: _MapPin(color: _categoryColor(g.subCategory)),
                    ),
                  );
                }).toList(),
              ),
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 20,
                      height: 20,
                      child: const _MyLocationDot(),
                    ),
                  ],
                ),
            ],
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NsgColor.black50,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: NsgSearchBar(
                      searchText: mapState.searchText,
                      hintText: '장소를 검색하세요.',
                      onChanged: _onSearchTextChanged,
                      onSubmitted: _onSearchTextChanged,
                      onClear: _clearSearch,
                      onFocusChanged: _onSearchFocusChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _CategoryChips(
                  selected: mapState.selectedCategory,
                  onSelected: (v) =>
                      ref.read(mapProvider.notifier).selectCategory(v),
                ),
                if (mapState.showSuggestions && suggestions.isNotEmpty)
                  _SearchSuggestionOverlay(
                    suggestions: suggestions,
                    onSelect: _selectSuggestion,
                  ),
                if (_locationLoading && _myLocation == null)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _LocationStatusCard(message: '현재 위치를 확인하고 있어요.'),
                  ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LocationFab(
                  isLoading: _locationLoading,
                  onTap: _moveToMyLocation,
                ),
                const SizedBox(height: 12),
                _WriteFab(onTap: () => context.push('/write/place')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  final String message;

  const _LocationStatusCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: NsgColor.background,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NsgColor.orange400,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            message,
            style: NsgTextStyle.body4.copyWith(color: NsgColor.black500),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;

  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Symbols.location_on, size: 36, color: color, fill: 1)],
    );
  }
}

class _MyLocationDot extends StatelessWidget {
  const _MyLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A73E8),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _LocationFab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationFab({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: NsgColor.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NsgColor.orange400,
                ),
              )
            : const Icon(
                Symbols.my_location,
                color: NsgColor.orange400,
                size: 22,
              ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ..._categoryColors.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: entry.key,
                isSelected: selected == entry.key,
                activeColor: entry.value.active,
                inactiveBgColor: entry.value.inactiveBg,
                inactiveTextColor: entry.value.inactiveText,
                onTap: () =>
                    onSelected(selected == entry.key ? null : entry.key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveBgColor;
  final Color inactiveTextColor;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveBgColor,
    required this.inactiveTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveBgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: NsgTextStyle.body3.copyWith(
            color: isSelected ? Colors.white : inactiveTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestionOverlay extends StatelessWidget {
  final List<PlaceGroup> suggestions;
  final ValueChanged<PlaceGroup> onSelect;

  const _SearchSuggestionOverlay({
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: NsgColor.black100),
          itemBuilder: (context, i) {
            final g = suggestions[i];
            return InkWell(
              onTap: () => onSelect(g),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.location_on,
                      size: 16,
                      color: _categoryColor(g.subCategory),
                      fill: 1,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.locationName,
                            style: NsgTextStyle.body3.copyWith(
                              color: NsgColor.black800,
                            ),
                          ),
                          Text(
                            g.locationAddress,
                            style: NsgTextStyle.body4.copyWith(
                              color: NsgColor.black400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CategoryBadge(subCategory: g.subCategory),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WriteFab extends StatelessWidget {
  final VoidCallback onTap;

  const _WriteFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: NsgColor.background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: const Icon(
          Symbols.edit_square_rounded,
          color: NsgColor.orange400,
          size: 24,
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String subCategory;

  const _CategoryBadge({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    final colors = _categoryColors[subCategory];
    final activeColor = colors?.active ?? NsgColor.black500;
    final bgColor = colors?.inactiveBg ?? NsgColor.background;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: activeColor, width: 0.5),
      ),
      child: Text(
        subCategory,
        style: NsgTextStyle.body4.copyWith(
          color: activeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PlaceBottomSheet extends StatelessWidget {
  final PlaceGroup place;
  final LatLng? myLocation;

  const _PlaceBottomSheet({required this.place, this.myLocation});

  Future<void> _openNaverMaps(BuildContext context) async {
    final destinationName = Uri.encodeComponent(place.locationName);
    final sourceQuery = myLocation != null
        ? '&slat=${myLocation!.latitude}&slng=${myLocation!.longitude}&sname=${Uri.encodeComponent('현재 위치')}'
        : '';

    final appUri = Uri.parse(
      'nmap://route/public?dlat=${place.latitude}&dlng=${place.longitude}&dname=$destinationName$sourceQuery&appname=com.example.nsg_mobile',
    );
    final webUri = Uri.parse(
      'https://map.naver.com/v5/search/${Uri.encodeComponent(place.locationName)}',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
    } else if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지도 앱을 열 수 없습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const String? image = null;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NsgColor.black100,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.locationName,
                      style: NsgTextStyle.header1.copyWith(
                        color: NsgColor.black800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.locationAddress,
                      style: NsgTextStyle.body4.copyWith(
                        color: NsgColor.black400,
                      ),
                    ),
                  ],
                ),
              ),

              if (image != null) ...[
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      image,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1, color: NsgColor.black100),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '위 장소가 포함된 글',
                  style: NsgTextStyle.body2.copyWith(
                    color: NsgColor.black800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Stack(
                  children: [
                    ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                      itemCount: place.posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final post = place.posts[i];
                        return RecentPostCard(
                          post: post,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/share/post/${post.id}');
                          },
                        );
                      },
                    ),

                    Positioned(
                      right: 20,
                      bottom: 20,
                      child: GestureDetector(
                        onTap: () => _openNaverMaps(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: NsgColor.orange400,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '길찾기',
                            style: NsgTextStyle.body3.copyWith(
                              color: NsgColor.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
