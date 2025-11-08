import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../services/transaction_service.dart';
import '../../services/auth_service.dart';
import '../../models/category_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TransactionService _transactionService = TransactionService();
  final AuthService _authService = AuthService();

  String _type = 'expense';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  List<Category> _categories = [];
  bool _isLoading = false;

  late NumberFormat _rupiahFormatter;

  @override
  void initState() {
    super.initState();
    _rupiahFormatter = NumberFormat.decimalPattern('id_ID');
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      final url = '${ApiConfig.categories}?type=$_type';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _categories = (data['data'] as List)
              .map((json) => Category.fromJson(json))
              .toList();
          _selectedCategory = _categories.isNotEmpty ? _categories[0] : null;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('id', 'ID'),
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final cleanAmount = _amountController.text.replaceAll('.', '');
    if (cleanAmount.isEmpty || double.tryParse(cleanAmount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }

    final amount = double.parse(cleanAmount);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tidak boleh nol')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _transactionService.createTransaction(
      categoryId: _selectedCategory!.id,
      amount: amount,
      type: _type,
      description: _descriptionController.text,
      date: _selectedDate,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menambahkan transaksi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatRupiah(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return '';
    return _rupiahFormatter.format(int.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leadingWidth: 45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        titleSpacing: 0,
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔁 Toggle tipe transaksi
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _selectedCategory = null;
                            _loadCategories();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'expense'
                                ? Colors.red
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _type == 'expense'
                                    ? Colors.white
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _selectedCategory = null;
                            _loadCategories();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'income'
                                ? Colors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _type == 'income'
                                    ? Colors.white
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatRupiah(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final clean = value.replaceAll('.', '');
                  if (double.tryParse(clean) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                initialValue: _categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : null,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.icon ?? ''} ${category.name}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal',
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy', 'id_ID')
                                .format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today,
                          color: Colors.blueAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
