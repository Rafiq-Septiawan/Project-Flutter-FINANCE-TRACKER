import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> getSummary({int? month, int? year}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      String url = ApiConfig.dashboardSummary;
      List<String> params = [];

      if (month != null) params.add('month=$month');
      if (year != null) params.add('year=$year');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
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
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMonthlyReport({int? year}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      String url = ApiConfig.monthlyReport;
      if (year != null) {
        url += '?year=$year';
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
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
