import 'dart:convert';
import 'package:http/http.dart' as http;

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
        // If the response is successful (status code 200), return the response body
        return jsonDecode(response.body);
      } else {
        // If the status code is not 200, handle the error
        // Assuming the server sends an error message in the body (e.g., "Invalid email or password")
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      // In case of network issues or other errors, return the error message
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

  // Fetch all profiles
  // Fetch all profiles
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

  // Search users by different properties (university, course, etc.)
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

  // Follow user function
  Future<void> followUser(int followerId, int followedId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/user/$followerId/follow/$followedId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to follow user');
    }
  }

  // Unfollow user function
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

  // Get followed users
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
}
