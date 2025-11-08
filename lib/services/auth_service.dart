import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      print('=== REGISTER REQUEST ===');
      print('URL: ${ApiConfig.register}');
      print('Name: $name');
      print('Email: $email');
      
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveToken(data['data']['token']);
        return {'success': true, 'user': User.fromJson(data['data']['user'])};
      } else {
        // Handle validation errors
        String errorMessage = 'Registration failed';
        
        if (data['errors'] != null) {
          // Laravel validation errors
          Map<String, dynamic> errors = data['errors'];
          List<String> errorList = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.cast<String>());
            }
          });
          errorMessage = errorList.join('\n');
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.\nPastikan Laravel API berjalan di:\n${ApiConfig.baseUrl}'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Server tidak merespon.'
      };
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('=== LOGIN REQUEST ===');
      print('URL: ${ApiConfig.login}');
      print('Email: $email');
      
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveToken(data['data']['token']);
        return {'success': true, 'user': User.fromJson(data['data']['user'])};
      } else {
        // Handle validation errors
        String errorMessage = 'Login failed';
        
        if (data['errors'] != null) {
          // Laravel validation errors
          Map<String, dynamic> errors = data['errors'];
          List<String> errorList = [];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.cast<String>());
            }
          });
          errorMessage = errorList.join('\n');
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server.\nPastikan Laravel API berjalan di:\n${ApiConfig.baseUrl}'
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Server tidak merespon.'
      };
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      await http.post(
        Uri.parse(ApiConfig.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _removeToken();
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  Future<User?> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}