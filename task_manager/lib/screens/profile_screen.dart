import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';
import '../models/task_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final taskService = Provider.of<TaskService>(context);
    final user = authService.currentUser;
    final String userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'User';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF0B0B0B), const Color(0xFF161616), const Color(0xFF0B0B0B)]
                : [const Color(0xFFFFF8E7), const Color(0xFFF7F1E3), const Color(0xFFFFF8E7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 32),
            _buildStatSummary(taskService, user?.uid ?? ''),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [

                  _profileOption(
                    context: context,
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.redAccent,
                    onTap: () {
                      authService.logout();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildStatSummary(TaskService service, String userId) {
    return StreamBuilder<List<TaskModel>>(
      stream: service.getTasks(userId),
      builder: (context, snapshot) {
        int total = snapshot.data?.length ?? 0;
        int done = snapshot.data?.where((t) => t.isCompleted).length ?? 0;
        double progress = total == 0 ? 0 : done / total;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.black.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black : Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  color: Theme.of(context).colorScheme.primary,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _simpleStat(context, 'Total', total.toString()),
                    _simpleStat(context, 'Completed', done.toString()),
                    _simpleStat(context, 'Efficiency', '${(progress * 100).toInt()}%'),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _simpleStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Widget _profileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}
