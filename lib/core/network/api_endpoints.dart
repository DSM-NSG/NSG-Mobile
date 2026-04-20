import 'package:nsg_mobile/core/config/app_env.dart';

class ApiEndpoints {
  /// BaseUrl
  static const baseUrl = AppEnv.baseUrl;

  /// Places
  static const  places = '/';
  static String placeDelete(int id) => '/$id/';

  /// Api
  static const schema = '/api/schema/';

  /// Majors
  static const majors = '/majors/';

  /// Comments
  static String createComment(int postId) => '/posts/$postId/comments/';
  static String deleteComment(int postId, commentId) => 'posts/$postId/comments/$commentId/delete/';
  static String replyComment(int postId, commentId) => 'posts/$postId/comments/$commentId/replies/';

  /// Likes
  static String toggleLike(int postId) => '/posts/$postId/like/';

  /// Major Posts
  static const majorPosts = '/posts/majors/';
  static String majorPostDetail(int id) => '/posts/major/$id/';
  static String deleteMajorPost(int id) => '/posts/major/$id/delete/';
  static const createMajorPost = '/posts/major/create/';

  /// Tips
  static const tipsPosts = '/posts/tips/';
  static String tipsPostDetail(int id) => '/posts/tips/$id/';
  static String deleteTipsPost(int id) => '/posts/tips/$id/delete/';
  static const createTipsPost = '/posts/tips/create/';

  /// Auth
  static const login = '/users/login/';

  /// Users
  static const testUser = '/users/test/';
}