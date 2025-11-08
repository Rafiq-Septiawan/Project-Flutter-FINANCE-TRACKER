import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category_model.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  Future<List<Category>> getCategories({String? type}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      String url = ApiConfig.categories;
      if (type != null) {
        url += '?type=$type';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Category?> getCategory(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.categories}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Category.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse(ApiConfig.categories),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'type': type,
          'icon': icon,
          'color': color,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'category': Category.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateCategory({
    required int id,
    String? name,
    String? type,
    String? icon,
    String? color,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (icon != null) body['icon'] = icon;
      if (color != null) body['color'] = color;

      final response = await http.put(
        Uri.parse('${ApiConfig.categories}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'category': Category.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.categories}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
