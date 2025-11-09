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

    try {
      final categories = await _categoryService.getCategories(type: type);

      if (type == null) {
        _categories = categories;
        _incomeCategories =
            categories.where((c) => c.type == 'income').toList();
        _expenseCategories =
            categories.where((c) => c.type == 'expense').toList();
      } else if (type == 'income') {
        _incomeCategories = categories;
      } else if (type == 'expense') {
        _expenseCategories = categories;
      }
    } catch (e) {
      _error = e.toString();
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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _categoryService.createCategory(
      name: name,
      type: type,
    );

    _isLoading = false;

    if (result['success'] == true) {
      final newCategory = result['data'] as Category?;
      if (newCategory != null) {
        _categories.add(newCategory);
        if (newCategory.type == 'income') {
          _incomeCategories.add(newCategory);
        } else if (newCategory.type == 'expense') {
          _expenseCategories.add(newCategory);
        }
      }
      notifyListeners();
      return true;
    } else {
      _error = result['message'] ?? 'Gagal menambah kategori';
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

    if (result['success'] == true) {
      final updated = result['category'] as Category?;
      if (updated != null) {
        final index = _categories.indexWhere((c) => c.id == updated.id);
        if (index != -1) {
          _categories[index] = updated;
        }
        // sinkronisasi income & expense list
        await loadCategories();
      }
      notifyListeners();
      return true;
    } else {
      _error = result['message'] ?? 'Gagal update kategori';
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
      _categories.removeWhere((c) => c.id == id);
      _incomeCategories.removeWhere((c) => c.id == id);
      _expenseCategories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } else {
      _error = 'Gagal menghapus kategori';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
