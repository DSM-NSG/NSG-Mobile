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

  static Future<List<NaverLocalItem>> search(
    String query, {
    double? nearLat,
    double? nearLon,
  }) async {
    if (query.trim().isEmpty) return [];

    final nearInfo = nearLat != null ? ' (근처 $nearLat,$nearLon)' : '';
    dev.log('장소 검색 시작: "$query"$nearInfo', name: 'LocationSearch');

    // When the user's location is known, bias the search with a ~30 km viewbox
    final viewbox = (nearLat != null && nearLon != null)
        ? '${nearLon - 0.3},${nearLat + 0.3},${nearLon + 0.3},${nearLat - 0.3}'
        : _koreaViewBox;

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
        'namedetails': 1,
        'accept-language': 'ko-KR,ko,en',
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      dev.log('장소 검색 실패: status=${response.statusCode}', name: 'LocationSearch');
      throw Exception('검색 API 오류: ${response.statusCode}');
    }

    final List<dynamic> rawList;
    if (response.data is List) {
      rawList = response.data as List<dynamic>;
    } else if (response.data is String) {
      rawList = jsonDecode(response.data as String) as List<dynamic>;
    } else {
      dev.log('장소 검색 응답 형식 오류: ${response.data.runtimeType}', name: 'LocationSearch');
      throw Exception('예상치 못한 응답 형식: ${response.data.runtimeType}');
    }

    dev.log('장소 검색 원본 결과: ${rawList.length}개', name: 'LocationSearch');

    var items = rawList
        .whereType<Map<String, dynamic>>()
        .map(NaverLocalItem.fromJson)
        .where((item) => item.isInSouthKorea)
        .fold<List<NaverLocalItem>>([], (acc, item) {
          final duplicated = acc.any(
            (saved) =>
                saved.plainTitle == item.plainTitle &&
                saved.displayAddress == item.displayAddress,
          );
          if (!duplicated) acc.add(item);
          return acc;
        })
        .toList();

    // Sort by distance to user's location when available
    if (nearLat != null && nearLon != null) {
      items.sort(
        (a, b) => _distanceSq(a.latitude, a.longitude, nearLat, nearLon)
            .compareTo(_distanceSq(b.latitude, b.longitude, nearLat, nearLon)),
      );
    }

    dev.log('장소 검색 최종 결과: ${items.length}개', name: 'LocationSearch');
    return items;
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
        (json['name'] as String?) ??
        (json['display_name'] as String?);
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
