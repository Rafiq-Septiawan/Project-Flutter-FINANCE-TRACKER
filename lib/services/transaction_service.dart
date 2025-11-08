import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transaction_model.dart';
import 'auth_service.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  Future<List<Transaction>> getTransactions({
    String? type,
    int? categoryId,
    String? startDate,
    String? endDate,
    int? month,
    int? year,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      String url = ApiConfig.transactions;
      List<String> params = [];

      if (type != null) params.add('type=$type');
      if (categoryId != null) params.add('category_id=$categoryId');
      if (startDate != null) params.add('start_date=$startDate');
      if (endDate != null) params.add('end_date=$endDate');
      if (month != null) params.add('month=$month');
      if (year != null) params.add('year=$year');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createTransaction({
    required int categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime date,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final body = {
        'category_id': categoryId,
        'amount': amount,
        'type': type,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
      };

      print('=== CREATE TRANSACTION ===');
      print('URL: ${ApiConfig.transactions}');
      print('Body: ${jsonEncode(body)}');

      final response = await http
          .post(
        Uri.parse(ApiConfig.transactions),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Cek apakah response adalah JSON
      if (!response.body.startsWith('{') && !response.body.startsWith('[')) {
        return {
          'success': false,
          'message':
              'Server error: Response bukan JSON. Cek Laravel log untuk detail error.'
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'transaction': Transaction.fromJson(data['data'])
        };
      } else {
        String errorMessage = 'Failed to create transaction';

        if (data['errors'] != null) {
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
    } catch (e) {
      print('Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTransaction({
    required int id,
    int? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      Map<String, dynamic> body = {};
      if (categoryId != null) body['category_id'] = categoryId;
      if (amount != null) body['amount'] = amount;
      if (type != null) body['type'] = type;
      if (description != null) body['description'] = description;
      if (date != null) body['date'] = date.toIso8601String().split('T')[0];

      final response = await http.put(
        Uri.parse('${ApiConfig.transactions}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'transaction': Transaction.fromJson(data['data'])
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.transactions}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
