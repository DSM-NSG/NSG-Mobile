import 'package:nsg_mobile/core/network/api_endpoints.dart';
import 'package:nsg_mobile/core/network/dio.dart';
import 'package:nsg_mobile/features/mypage/data/models/user_model.dart';

class UserService {
  final DioClient _client;

  const UserService(this._client);

  Future<UserModel> getMe() async {
    final response = await _client.dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
