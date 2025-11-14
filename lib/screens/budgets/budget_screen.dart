import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/budget_model.dart';
import '../../helper/icon_helper.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedDate = DateTime.now();
  final _rupiahFormatter = NumberFormat.decimalPattern('id_ID');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<BudgetProvider>(context, listen: false)
        .loadBudgets(month: _selectedDate.month, year: _selectedDate.year);
    // ignore: use_build_context_synchronously
    await Provider.of<CategoryProvider>(context, listen: false)
        .loadCategories(type: 'expense');
    if (!mounted) return;
  }

  Future<void> _changeMonth(int delta) async {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month + delta);
    setState(() => _selectedDate = newDate);
    await _loadData();
    if (!mounted) return;
  }

  Color _parseColor(String? hexColor) {
    try {
      if (hexColor == null || hexColor.isEmpty) return Colors.grey;
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

void _showAddBudgetDialog({Budget? budget}) async {
  final isEdit = budget != null;
  final amountController = TextEditingController(
    text: budget != null
        ? NumberFormat.decimalPattern('id_ID').format(budget.amount)
        : '',
  );

  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

  if (categoryProvider.expenseCategories.isEmpty) {
    await categoryProvider.loadCategories(type: 'expense');
    if (!mounted) return;
  }

  int? selectedCategoryId = budget?.category?.id;

  if (!mounted) return;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isEdit ? Icons.edit : Icons.add,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(isEdit ? 'Edit Budget' : 'Tambah Budget'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<CategoryProvider>(
                builder: (context, provider, _) {
                  if (provider.expenseCategories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  selectedCategoryId ??= provider.expenseCategories.first.id;

                  return DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(Icons.category, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: provider.expenseCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(
                              getMaterialIcon(category.icon ?? ''),
                              size: 20,
                              color: _parseColor(category.color),
                            ),
                            const SizedBox(width: 10),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategoryId = value),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final value = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
                    if (value.isEmpty) return const TextEditingValue();
                    final formatted = _rupiahFormatter.format(int.parse(value));
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                decoration: InputDecoration(
                  labelText: 'Jumlah Budget',
                  prefixIcon: const Icon(Icons.payments, color: Colors.blue),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (selectedCategoryId == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pilih kategori terlebih dahulu!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (amountController.text.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan jumlah budget!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final cleanAmount = amountController.text.replaceAll('.', '').replaceAll(',', '');
                      final amount = double.tryParse(cleanAmount);

                      if (amount == null || amount <= 0) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Jumlah harus lebih dari 0!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (!mounted) return;
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final provider = Provider.of<BudgetProvider>(context, listen: false);
                        bool success;

                        if (isEdit) {
                          success = await provider.updateBudget(
                            id: budget!.id,
                            categoryId: selectedCategoryId!,
                            amount: amount,
                            month: _selectedDate.month,
                            year: _selectedDate.year,
                          );
                        } else {
                          success = await provider.createBudget(
                            categoryId: selectedCategoryId!,
                            amount: amount,
                            month: _selectedDate.month,
                            year: _selectedDate.year,
                          );
                        }

                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        if (success) {
                          await _loadData();
                          if (!mounted) return;
                        }

                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? (isEdit ? 'Budget berhasil diupdate!' : 'Budget berhasil ditambahkan!')
                                : 'Gagal menyimpan budget. Coba lagi.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -80,
                    bottom: -80,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 25,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.wallet_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'Budget',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Padding(
                              padding: EdgeInsets.only(left: 40),
                              child: Text(
                                'Kelola budget bulanan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                monthYear,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<BudgetProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.budgets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wallet, size: 80, color: Colors.blue.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text('Belum ada budget',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Mulai tambahkan budget untuk bulan ini',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(provider, currencyFormat),
                          const SizedBox(height: 24),
                          const Text('Budget per Kategori',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.budgets.length,
                            itemBuilder: (context, index) {
                              final budget = provider.budgets[index];
                              final percentage = budget.percentage ?? 0;
                              final spent = budget.spent ?? 0;
                              final remaining = budget.remaining ?? 0;

                              Color statusColor = Colors.green;
                              if (percentage >= 100) {
                                statusColor = Colors.red;
                              } else if (percentage >= 80) {
                                statusColor = Colors.orange;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              getMaterialIcon(budget.category?.icon ?? ''),
                                              color: statusColor,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  budget.category?.name ?? 'Unknown',
                                                  style: const TextStyle(
                                                      fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  currencyFormat.format(budget.amount),
                                                  style: TextStyle(
                                                      fontSize: 13, color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${percentage.toStringAsFixed(0)}%',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: statusColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: percentage > 100 ? 1.0 : percentage / 100,
                                          backgroundColor: Colors.grey[200],
                                          color: statusColor,
                                          minHeight: 8,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Terpakai: ${currencyFormat.format(spent)}',
                                              style: const TextStyle(fontSize: 13)),
                                          Text(
                                            'Sisa: ${currencyFormat.format(remaining)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: remaining >= 0 ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                            onPressed: () => _showAddBudgetDialog(budget: budget),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                            onPressed: () => _deleteBudget(budget.id, provider),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_budget",
        onPressed: () => _showAddBudgetDialog(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSummaryCard(BudgetProvider provider, NumberFormat format) {
    final totalAllocated = provider.totalBudget;
    final unallocated = provider.totalIncome - totalAllocated;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _summaryRow(Icons.trending_up, 'Pemasukan Bulan Ini',
              format.format(provider.totalIncome), Colors.greenAccent),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 14),
          _summaryRow(Icons.trending_down, 'Total Pengeluaran',
              format.format(provider.totalSpent), Colors.redAccent),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 14),
          _summaryRow(Icons.assignment_turned_in, 'Budget Dialokasikan',
              format.format(totalAllocated), Colors.white),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 14),
          _summaryRow(
              Icons.hourglass_empty,
              'Belum Dialokasikan',
              format.format(unallocated),
              unallocated >= 0 ? Colors.yellowAccent : Colors.redAccent),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          const SizedBox(height: 14),
          _summaryRow(
              Icons.account_balance_wallet,
              'Sisa Budget',
              format.format(provider.totalRemaining),
              provider.totalRemaining >= 0 ? Colors.greenAccent : Colors.redAccent),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String title, String value, Color valueColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteBudget(int id, BudgetProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Budget'),
        content: const Text('Yakin ingin menghapus budget ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      final success = await provider.deleteBudget(id);
      if (!mounted) return;
      if (success && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Budget dihapus')));
      }
    }
  }
}