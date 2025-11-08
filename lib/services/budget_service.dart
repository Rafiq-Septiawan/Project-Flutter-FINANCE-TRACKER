import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/budget_model.dart';
import 'auth_service.dart';

class BudgetService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getBudgetsWithIncome({int? month, int? year}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        print('getBudgets: Token null');
        return {'budgets': [], 'total_income': 0.0};
      }

      String url = ApiConfig.budgets;
      List<String> params = [];

      if (month != null) params.add('month=$month');
      if (year != null) params.add('year=$year');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final budgetsData = data['data'];
        
        if (budgetsData is Map && budgetsData.containsKey('budgets')) {
          final budgets = (budgetsData['budgets'] as List)
              .map((json) => Budget.fromJson(json))
              .toList();
          
          final totalIncome = double.tryParse(budgetsData['total_income']?.toString() ?? '0') ?? 0.0;
          
          print('Parsed ${budgets.length} budgets, Income: Rp ${totalIncome.toStringAsFixed(0)}');
          
          return {
            'budgets': budgets,
            'total_income': totalIncome,
          };
        } else {
          // Fallback for old format
          final budgets = (data['data'] as List)
              .map((json) => Budget.fromJson(json))
              .toList();
          print('Parsed ${budgets.length} budgets (old format)');
          return {
            'budgets': budgets,
            'total_income': 0.0,
          };
        }
      }
      print('Status bukan 200');
      return {'budgets': [], 'total_income': 0.0};
    } catch (e) {
      print('Exception getBudgets: $e');
      return {'budgets': [], 'total_income': 0.0};
    }
  }

  // Method lama: untuk backward compatibility
  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    final result = await getBudgetsWithIncome(month: month, year: year);
    return result['budgets'] as List<Budget>;
  }

  Future<Budget?> getBudget(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.budgets}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Budget.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('getBudget error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = ApiConfig.budgets;
      final body = {
        'category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      };

      print('POST $url');
      print('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Status: ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('Budget created successfully');
        return {'success': true, 'budget': Budget.fromJson(data['data'])};
      } else {
        print('Failed: ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      print('Exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateBudget({
    required int id,
    int? categoryId,
    double? amount,
    int? month,
    int? year,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      Map<String, dynamic> body = {};
      if (categoryId != null) body['category_id'] = categoryId;
      if (amount != null) body['amount'] = amount;
      if (month != null) body['month'] = month;
      if (year != null) body['year'] = year;

      final response = await http.put(
        Uri.parse('${ApiConfig.budgets}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'budget': Budget.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      print('updateBudget error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.budgets}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('deleteBudget error: $e');
      return false;
    }
  }
}