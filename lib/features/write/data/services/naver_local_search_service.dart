import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dio/dio.dart';

class NaverLocalSearchService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const _koreaViewBox = '124.5,38.9,131.9,33.0';

  static bool _isInKorea(double lat, double lon) =>
      lat >= 33.0 && lat <= 38.9 && lon >= 124.5 && lon <= 131.9;

  static Future<List<NaverLocalItem>> search(
    String query, {
    double? nearLat,
    double? nearLon,
  }) async {
    if (query.trim().isEmpty) return [];

    final hasLocation = nearLat != null &&
        nearLon != null &&
        _isInKorea(nearLat, nearLon);
    dev.log(
      '장소 검색 시작: "$query"${hasLocation ? ' (내 위치 $nearLat,$nearLon)' : ' (위치 없음 또는 해외)'}',
      name: 'LocationSearch',
    );

    List<NaverLocalItem> items = [];

    if (hasLocation) {
      final localViewbox =
          '${nearLon - 0.3},${nearLat + 0.3},${nearLon + 0.3},${nearLat - 0.3}';
      final localRaw = await _fetch(query, viewbox: localViewbox, bounded: true);
      items = _parse(localRaw);
      dev.log('1단계(근처 bounded): ${items.length}개', name: 'LocationSearch');
    }

    if (items.length < 3) {
      if (hasLocation) await Future.delayed(const Duration(milliseconds: 1100));
      final koreaRaw = await _fetch(query, viewbox: _koreaViewBox, bounded: true);
      final koreaItems = _parse(koreaRaw);
      dev.log('2단계(한국 bounded): ${koreaItems.length}개', name: 'LocationSearch');

      final seen = <String>{
        for (final i in items) '${i.plainTitle}||${i.displayAddress}',
      };
      for (final item in koreaItems) {
        final key = '${item.plainTitle}||${item.displayAddress}';
        if (seen.add(key)) items.add(item);
      }
    }

    if (hasLocation) {
      items.sort(
        (a, b) => _distanceSq(a.latitude, a.longitude, nearLat, nearLon)
            .compareTo(_distanceSq(b.latitude, b.longitude, nearLat, nearLon)),
      );
    }

    dev.log('장소 검색 최종 결과: ${items.length}개', name: 'LocationSearch');
    return items;
  }

  static Future<List<dynamic>> _fetch(
    String query, {
    required String viewbox,
    required bool bounded,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'ko-KR,ko;q=1.0,en;q=0.3',
          'User-Agent': 'NSG-Mobile/1.0 (contact: support@nsg-mobile.app)',
          'Referer': 'https://nsg-mobile.app',
        },
        responseType: ResponseType.json,
      ),
      queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'limit': 10,
        'addressdetails': 1,
        'dedupe': 1,
        'countrycodes': 'kr',
        'viewbox': viewbox,
        'bounded': bounded ? 1 : 0,
        'namedetails': 1,
        'accept-language': 'ko-KR,ko,en',
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      dev.log('장소 검색 실패: status=${response.statusCode}', name: 'LocationSearch');
      throw Exception('검색 API 오류: ${response.statusCode}');
    }

    if (response.data is List) return response.data as List<dynamic>;
    if (response.data is String) {
      return jsonDecode(response.data as String) as List<dynamic>;
    }
    throw Exception('예상치 못한 응답 형식: ${response.data.runtimeType}');
  }

  static List<NaverLocalItem> _parse(List<dynamic> rawList) {
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(NaverLocalItem.fromJson)
        .where((item) => item.isInSouthKorea)
        .fold<List<NaverLocalItem>>([], (acc, item) {
          final key = '${item.plainTitle}||${item.displayAddress}';
          if (acc.every((s) => '${s.plainTitle}||${s.displayAddress}' != key)) {
            acc.add(item);
          }
          return acc;
        });
  }

  static double _distanceSq(double lat1, double lon1, double lat2, double lon2) {
    final dLat = lat1 - lat2;
    final dLon = (lon1 - lon2) * cos((lat1 + lat2) / 2 * pi / 180);
    return dLat * dLat + dLon * dLon;
  }
}

class NaverLocalItem {
  final String title;
  final String category;
  final String address;
  final String roadAddress;
  final String countryCode;
  final double latitude;
  final double longitude;

  const NaverLocalItem({
    required this.title,
    required this.category,
    required this.address,
    required this.roadAddress,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  String get plainTitle => title.replaceAll(RegExp(r'<[^>]*>'), '');

  String get displayAddress => roadAddress.isNotEmpty ? roadAddress : address;

  bool get isInSouthKorea => countryCode.toLowerCase() == 'kr';

  factory NaverLocalItem.fromJson(Map<String, dynamic> json) {
    final address = json['display_name'] as String? ?? '';
    final addressMap = json['address'] is Map<String, dynamic>
        ? json['address'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final nameDetails = json['namedetails'] is Map<String, dynamic>
        ? json['namedetails'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final preferredName =
        (nameDetails['name:ko'] as String?) ??
        (nameDetails['official_name:ko'] as String?) ??
        (addressMap['amenity'] as String?) ??
        (addressMap['shop'] as String?) ??
        (addressMap['building'] as String?) ??
        (addressMap['tourism'] as String?) ??
        (json['name'] as String?);
    final displayTitle =
        preferredName != null && preferredName.trim().isNotEmpty
        ? preferredName.trim()
        : address.split(',').first.trim();
    final city =
        (addressMap['city'] as String?) ??
        (addressMap['state'] as String?) ??
        (addressMap['province'] as String?) ??
        '';
    final district =
        (addressMap['county'] as String?) ??
        (addressMap['suburb'] as String?) ??
        (addressMap['city_district'] as String?) ??
        '';
    final type = json['type'] as String? ?? '';
    return NaverLocalItem(
      title: displayTitle,
      category: [
        city,
        district,
        type,
      ].where((value) => value.isNotEmpty).join(' · '),
      address: address,
      roadAddress: address,
      countryCode: addressMap['country_code'] as String? ?? '',
      latitude: double.tryParse(json['lat'] as String? ?? '') ?? 0,
      longitude: double.tryParse(json['lon'] as String? ?? '') ?? 0,
    );
  }
}

class LocationResult {
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  const LocationResult({
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });

  static LocationResult fromNaverItem(NaverLocalItem item) {
    return LocationResult(
      name: item.plainTitle,
      address: item.displayAddress,
      latitude: item.latitude,
      longitude: item.longitude,
    );
  }
}
