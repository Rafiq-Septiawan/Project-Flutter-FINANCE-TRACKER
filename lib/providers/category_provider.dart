import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  List<Category> get incomeCategories => _incomeCategories;
  List<Category> get expenseCategories => _expenseCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories({String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final categories = await _categoryService.getCategories(type: type);

    if (type == null) {
      _categories = categories;
      _incomeCategories = categories.where((c) => c.type == 'income').toList();
      _expenseCategories =
          categories.where((c) => c.type == 'expense').toList();
    } else if (type == 'income') {
      _incomeCategories = categories;
    } else if (type == 'expense') {
      _expenseCategories = categories;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Category?> getCategory(int id) async {
    return await _categoryService.getCategory(id);
  }

  Future<bool> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _categoryService.createCategory(
      name: name,
      type: type,
      icon: icon,
      color: color,
    );

    _isLoading = false;

    if (result['success']) {
      await loadCategories();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory({
    required int id,
    String? name,
    String? type,
    String? icon,
    String? color,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _categoryService.updateCategory(
      id: id,
      name: name,
      type: type,
      icon: icon,
      color: color,
    );

    _isLoading = false;

    if (result['success']) {
      await loadCategories();
      return true;
    } else {
      _error = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _categoryService.deleteCategory(id);

    _isLoading = false;

    if (success) {
      await loadCategories();
      return true;
    } else {
      _error = 'Failed to delete category';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
