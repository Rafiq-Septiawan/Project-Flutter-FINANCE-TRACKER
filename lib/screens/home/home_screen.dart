import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaction_service.dart';
import '../../models/transaction_model.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_list_screen.dart';
import '../categories/category_screen.dart';
import '../budgets/budget_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final TransactionService _transactionService = TransactionService();
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final transactions = await _transactionService.getTransactions(
      month: now.month,
      year: now.year,
    );

    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    setState(() {
      _recentTransactions = transactions.take(5).toList();
      _totalIncome = income;
      _totalExpense = expense;
      _balance = income - expense;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showSuccessPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 50),
              ),
              const SizedBox(height: 20),
              const Text('Sukses!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get _pages => [
        const CategoryScreen(),
        const BudgetScreen(),
        _buildHomeContent(),
        const TransactionListScreen(),
        const ProfileScreen(),
      ];

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 2) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              heroTag: "fab_home",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
                if (result == true) {
                  await _loadData();
                  _showSuccessPopup("Transaksi berhasil ditambahkan");

                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, Colors.blue.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Diamond pattern
                            Positioned(
                              left: -30,
                              top: 20,
                              child: Transform.rotate(
                                angle: 0.5,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: -20,
                              child: Transform.rotate(
                                angle: 0.8,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -20,
                              bottom: 20,
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 26),
                                          SizedBox(width: 10),
                                          Text(
                                            'Finance Tracker',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: _logout,
                                        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Total Saldo',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currencyFormat.format(_balance),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    title: 'Pemasukan',
                                    amount: currencyFormat.format(_totalIncome),
                                    icon: Icons.trending_up,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildSummaryCard(
                                    title: 'Pengeluaran',
                                    amount: currencyFormat.format(_totalExpense),
                                    icon: Icons.trending_down,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaksi Terbaru',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _selectedIndex = 3);
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _recentTransactions.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _recentTransactions.length,
                                    itemBuilder: (context, index) {
                                      final t = _recentTransactions[index];
                                      return _buildTransactionCard(t, currencyFormat);
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction t, NumberFormat f) {
    final isIncome = t.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(t.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (t.description != null && t.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      t.description!,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              f.format(t.amount),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.blue.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Belum ada transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk menambah transaksi',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}