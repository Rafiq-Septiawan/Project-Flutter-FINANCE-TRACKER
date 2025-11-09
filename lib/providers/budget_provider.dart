import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;
  double _totalIncome = 0.0;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalIncome => _totalIncome;

  double get totalBudget => _budgets.fold(0.0, (sum, b) => sum + b.amount);

  double get totalSpent => _budgets.fold(0.0, (sum, b) => sum + (b.spent ?? 0));

  double get totalRemaining => totalBudget - totalSpent;

  List<Budget> get overBudget =>
      _budgets.where((b) => (b.spent ?? 0) > b.amount).toList();

  List<Budget> get nearLimit => _budgets
      .where((b) => (b.percentage ?? 0) >= 80 && (b.percentage ?? 0) <= 100)
      .toList();

  Future<void> loadBudgets({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('Loading budgets - month: $month, year: $year');

    final result = await _budgetService.getBudgetsWithIncome(
      month: month,
      year: year,
    );

    final budgets = result['budgets'] as List<Budget>;
    final income = result['total_income'] as double;

    print('BudgetProvider loaded: ${budgets.length} budgets, Income: Rp ${income.toStringAsFixed(0)}');

    _budgets = budgets;
    _totalIncome = income;
    _isLoading = false;
    notifyListeners();
  }

  Future<Budget?> getBudget(int id) async {
    return await _budgetService.getBudget(id);
  }

  Future<bool> createBudget({
    required int categoryId,
    required double amount,
    required int month,
    required int year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('BudgetProvider.createBudget called');
    print('categoryId: $categoryId, amount: $amount, month: $month, year: $year');

    final result = await _budgetService.createBudget(
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
    );

    print('BudgetService result: $result');

    _isLoading = false;

    if (result['success']) {
      await loadBudgets(month: month, year: year);
      return true;
    } else {
      _error = result['message'];
      print('Error from service: $_error');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget({
    required int id,
    int? categoryId,
    double? amount,
    int? month,
    int? year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _budgetService.updateBudget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      month: month,
      year: year,
    );

    _isLoading = false;

    if (result['success']) {
      await loadBudgets();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _budgetService.deleteBudget(id);

    _isLoading = false;

    if (success) {
      await loadBudgets();
      return true;
    } else {
      _error = 'Failed to delete budget';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
