import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _monthlyReport;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get summary => _summary;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Summary data getters
  double get currentIncome =>
      _summary?['current_month']?['income']?.toDouble() ?? 0.0;

  double get currentExpense =>
      _summary?['current_month']?['expense']?.toDouble() ?? 0.0;

  double get currentBalance =>
      _summary?['current_month']?['balance']?.toDouble() ?? 0.0;

  double get allTimeIncome =>
      _summary?['all_time']?['income']?.toDouble() ?? 0.0;

  double get allTimeExpense =>
      _summary?['all_time']?['expense']?.toDouble() ?? 0.0;

  double get allTimeBalance =>
      _summary?['all_time']?['balance']?.toDouble() ?? 0.0;

  List<dynamic> get recentTransactions =>
      _summary?['recent_transactions'] ?? [];

  List<dynamic> get expenseByCategory => _summary?['expense_by_category'] ?? [];

  List<dynamic> get incomeByCategory => _summary?['income_by_category'] ?? [];

  Future<void> loadSummary({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final summary = await _dashboardService.getSummary(
      month: month,
      year: year,
    );

    if (summary != null) {
      _summary = summary;
    } else {
      _error = 'Failed to load summary';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMonthlyReport({int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final report = await _dashboardService.getMonthlyReport(year: year);

    if (report != null) {
      _monthlyReport = report;
    } else {
      _error = 'Failed to load monthly report';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _summary = null;
    _monthlyReport = null;
    notifyListeners();
  }
}
