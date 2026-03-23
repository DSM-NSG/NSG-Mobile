import 'dart:convert';
import 'package:http/http.dart' as http;

/// 네이버 지역 검색 API 서비스
///
/// 사용 전 네이버 개발자센터(https://developers.naver.com)에서
/// 애플리케이션 등록 후 Client ID / Secret을 발급받아 입력
class NaverLocalSearchService {
  static const _clientId = 'YOUR_NAVER_CLIENT_ID';
  static const _clientSecret = 'YOUR_NAVER_CLIENT_SECRET';
  static const _baseUrl =
      'https://openapi.naver.com/v1/search/local.json';

  static Future<List<NaverLocalItem>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'query': query,
        'display': '10',
        'start': '1',
        'sort': 'random',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('네이버 검색 API 오류: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (json['items'] as List<dynamic>)
        .map((e) => NaverLocalItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return items;
  }
}

class NaverLocalItem {
  /// 장소명 (HTML 태그 포함 가능)
  final String title;
  final String category;
  final String address;
  final String roadAddress;

  const NaverLocalItem({
    required this.title,
    required this.category,
    required this.address,
    required this.roadAddress,
  });

  /// 장소명에서 HTML 태그 제거
  String get plainTitle => title.replaceAll(RegExp(r'<[^>]*>'), '');

  /// 표시용 주소 (도로명 우선)
  String get displayAddress =>
      roadAddress.isNotEmpty ? roadAddress : address;

  factory NaverLocalItem.fromJson(Map<String, dynamic> json) {
    return NaverLocalItem(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      address: json['address'] as String? ?? '',
      roadAddress: json['roadAddress'] as String? ?? '',
    );
  }
}
