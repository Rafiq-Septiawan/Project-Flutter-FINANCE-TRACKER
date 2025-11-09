class ApiConfig {
  static const String baseUrl = 'http://192.168.100.205:8000';

  static const String register = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String logout = '$baseUrl/api/logout';
  static const String profile = '$baseUrl/api/profile';

  // Category endpoints
  static const String categories = '$baseUrl/api/categories';

  static const String transactions = '$baseUrl/api/transactions';

  static const String budgets = '$baseUrl/api/budgets';

  static const String dashboardSummary = '$baseUrl/api/dashboard/summary';
  static const String monthlyReport = '$baseUrl/api/dashboard/monthly-report';
}
