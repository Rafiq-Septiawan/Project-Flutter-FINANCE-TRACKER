class ApiConfig {
  // ============================================
  // GUNAKAN IP KOMPUTER ANDA: 192.168.251.164
  // ============================================

  static const String baseUrl = 'http://192.168.100.203:8000';

  // ============================================
  // JANGAN UBAH YANG DI BAWAH INI
  // ============================================

  // Auth endpoints
  static const String register = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String logout = '$baseUrl/api/logout';
  static const String profile = '$baseUrl/api/profile';

  // Category endpoints
  static const String categories = '$baseUrl/api/categories';

  // Transaction endpoints
  static const String transactions = '$baseUrl/api/transactions';

  // Budget endpoints
  static const String budgets = '$baseUrl/api/budgets';

  // Dashboard endpoints
  static const String dashboardSummary = '$baseUrl/api/dashboard/summary';
  static const String monthlyReport = '$baseUrl/api/dashboard/monthly-report';
}
