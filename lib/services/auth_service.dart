import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
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
}
