import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Transaction> get incomeTransactions =>
      _transactions.where((t) => t.type == 'income').toList();

  List<Transaction> get expenseTransactions =>
      _transactions.where((t) => t.type == 'expense').toList();

  double get totalIncome =>
      incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions({
    String? type,
    int? categoryId,
    String? startDate,
    String? endDate,
    int? month,
    int? year,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final transactions = await _transactionService.getTransactions(
      type: type,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      month: month,
      year: year,
    );

    _transactions = transactions;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTransaction({
    required int categoryId,
    required double amount,
    required String type,
    String? description,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _transactionService.createTransaction(
      categoryId: categoryId,
      amount: amount,
      type: type,
      description: description,
      date: date,
    );

    _isLoading = false;

    if (result['success']) {
      await loadTransactions();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction({
    required int id,
    int? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _transactionService.updateTransaction(
      id: id,
      categoryId: categoryId,
      amount: amount,
      type: type,
      description: description,
      date: date,
    );

    _isLoading = false;

    if (result['success']) {
      await loadTransactions();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _transactionService.deleteTransaction(id);

    _isLoading = false;

    if (success) {
      await loadTransactions();
      return true;
    } else {
      _error = 'Failed to delete transaction';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
