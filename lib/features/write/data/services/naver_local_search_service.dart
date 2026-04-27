import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

class NaverLocalSearchService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const _southKoreaViewBox = '124.5,38.9,131.9,33.0';

  static Future<List<NaverLocalItem>> search(String query) async {
    if (query.trim().isEmpty) return [];

    log('장소 검색 시작: "$query"', name: 'LocationSearch');

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
        'viewbox': _southKoreaViewBox,
        'namedetails': 1,
        'accept-language': 'ko-KR,ko,en',
      },
    );

    if (response.statusCode != 200 || response.data == null) {
      log('장소 검색 실패: status=${response.statusCode}', name: 'LocationSearch');
      throw Exception('검색 API 오류: ${response.statusCode}');
    }

    // Dio may return already-parsed List or a raw JSON String depending on content-type
    final List<dynamic> rawList;
    if (response.data is List) {
      rawList = response.data as List<dynamic>;
    } else if (response.data is String) {
      rawList = jsonDecode(response.data as String) as List<dynamic>;
    } else {
      log('장소 검색 응답 형식 오류: ${response.data.runtimeType}', name: 'LocationSearch');
      throw Exception('예상치 못한 응답 형식: ${response.data.runtimeType}');
    }

    log('장소 검색 결과: ${rawList.length}개', name: 'LocationSearch');

    final items = rawList
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

    log('장소 검색 최종 결과: ${items.length}개', name: 'LocationSearch');
    return items;
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
