import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password,
    String bestFriendName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
        'bestFriendName': bestFriendName,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchProfile(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>> changePassword(
    int userId,
    String newPassword,
  ) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/api/user/$userId/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword}),
    );
    return jsonDecode(response.body);
  }

  Future<bool> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }

  Future<bool> updateProfile(Map<String, dynamic> profile) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/api/user/update/${profile['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'collegeName': profile['collegeName'],
        'universityName': profile['universityName'],
        'courseName': profile['courseName'],
      }),
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getAllProfiles() async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8080/api/user/all',
      ), // Correct URL for fetching all profiles
    );

    print('Request URL: http://10.0.2.2:8080/api/user/all');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return List<dynamic>.from(
        jsonDecode(response.body),
      ); // Parse the response
    } else {
      print('Error Response: ${response.body}');
      throw Exception('Failed to load profiles');
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse(
        'http://10.0.2.2:8080/api/user/search?query=$query',
      ), // Correct URL for search with query parameter
    );

    print('Request URL: http://10.0.2.2:8080/api/user/search?query=$query');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return List<dynamic>.from(
        jsonDecode(response.body),
      ); // Parse the response
    } else {
      print('Error Response: ${response.body}');
      throw Exception('Failed to search users');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(
    String email,
    String bestFriendName,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'bestFriendName': bestFriendName,
        'newPassword': newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<void> followUser(int followerId, int followedId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/user/$followerId/follow/$followedId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to follow user');
    }
  }

  Future<void> unfollowUser(int followerId, int followedId) async {
    final url =
        'http://10.0.2.2:8080/api/user/$followerId/unfollow/$followedId';
    print('Attempting to unfollow at $url');
    final response = await http.delete(Uri.parse(url));
    print('Unfollow response: ${response.statusCode} — ${response.body}');
    if (response.statusCode != 200 ||
        response.body.toLowerCase().contains('failed')) {
      throw Exception(
        'Failed to unfollow user: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List<dynamic>> getFollowedUsers(int userId) async {
    final url = 'http://10.0.2.2:8080/api/user/$userId/following';
    print('Fetching followed users from: $url');

    final response = await http.get(Uri.parse(url));

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('Decoded response: $decoded');
      return decoded;
    } else if (response.statusCode == 204) {
      // No content means no followed users
      print('No followed users found.');
      return []; // Return empty list
    } else {
      throw Exception('Failed to load followed users: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getFollowers(int userId) async {
    final url = 'http://10.0.2.2:8080/api/user/$userId/followers';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 204) {
      // No one is following you
      return [];
    } else {
      throw Exception('Failed to load followers');
    }
  }

  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8080'));

  Future<List<dynamic>> fetchRandom() async {
    final res = await _dio.get('/api/notes/random');
    return res.data as List;
  }

  Future<List<dynamic>> search(String q) async {
    final res = await _dio.get(
      '/api/notes/search',
      queryParameters: {'query': q},
    );
    return res.data as List;
  }

  Future<void> upload(
    File file,
    String title,
    String keywords,
    String userId,
  ) async {
    try {
      FormData form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'title': title,
        'keywords': keywords,
        'userId': userId,
      });

      Response res = await _dio.post(
        '/api/notes/upload',
        data: form,
        options: Options(responseType: ResponseType.plain),
      );

      print('Upload response: ${res.data}');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<List<dynamic>> fetchAllNotes({int page = 0, int size = 100}) async {
    final response = await _dio.get(
      '/api/notes/all',
      queryParameters: {'page': page, 'size': size},
    );
    print('📥 Received ${response.data.length} notes');
    return response.data as List;
  }
}
