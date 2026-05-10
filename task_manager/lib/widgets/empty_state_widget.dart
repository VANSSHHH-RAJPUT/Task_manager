import 'dart:ui';
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAddPressed;

  const EmptyStateWidget({
    super.key,
    this.message = 'Looks like you have a free day!\nAdd your first task to get started.',
    this.icon = Icons.task_alt,
    this.onAddPressed,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.black.withOpacity(0.4) : const Color(0xFFFFF8E7).withOpacity(0.8),
                border: Border.all(color: isDark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFFD4AF37).withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFFD4AF37).withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Icon(widget.icon, size: 80, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.onAddPressed != null)
            ElevatedButton.icon(
              onPressed: widget.onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Add your first task', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
        ],
      ),
    );
  }
}
