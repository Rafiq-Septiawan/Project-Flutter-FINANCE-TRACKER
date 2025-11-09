import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 206,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -100,
                      top: -50,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -50,
                      top: 50,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 60,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -30,
                      bottom: 30,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow(Icons.person_rounded, 'Nama', name),
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.email_rounded, 'Email', email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _showLogoutDialog(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          // ⬅️ tambahin ini biar bisa discroll
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Keluar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
