import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category_model.dart';
import 'auth_service.dart';

class CategoryService {
  final AuthService _authService = AuthService();

  // Ambil semua kategori
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

  // Ambil kategori by ID
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

  // Tambah kategori baru
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

      final body = {
        'name': name,
        'type': type,
      };

      if (icon != null) body['icon'] = icon;
      if (color != null) body['color'] = color;

      final response = await http.post(
        Uri.parse(ApiConfig.categories),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'category': Category.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal menambah kategori'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update kategori
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

      final body = <String, dynamic>{};
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

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'category': Category.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Gagal update kategori'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Hapus kategori
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
