import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final Function(bool?) onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case 'High': return const Color(0xFFCF6679); // Muted red
      case 'Medium': return const Color(0xFFD4AF37); // Gold
      case 'Low': return const Color(0xFF81C784); // Muted green
      default: return const Color(0xFFD4AF37);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = !widget.task.isCompleted && widget.task.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.task.isCompleted 
                  ? Colors.green.withOpacity(0.5) 
                  : (isDark ? const Color(0xFFD4AF37).withOpacity(0.3) : const Color(0xFFD4AF37).withOpacity(0.2)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0xFFD4AF37).withOpacity(0.1) : const Color(0xFFB68A1E).withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: widget.task.isCompleted
                    ? Colors.green.withOpacity(0.05)
                    : (isDark ? Colors.black.withOpacity(0.5) : const Color(0xFFFFF8E7).withOpacity(0.7)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: widget.task.isCompleted,
                          onChanged: widget.onToggle,
                          activeColor: Colors.green,
                          checkColor: Theme.of(context).colorScheme.onPrimary,
                          side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: widget.task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                      color: widget.task.isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4) : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    child: Text(widget.task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.task.isCompleted ? Colors.green.withOpacity(0.1) : const Color(0xFFD4AF37).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: widget.task.isCompleted ? Colors.green.withOpacity(0.5) : const Color(0xFFD4AF37).withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    widget.task.isCompleted ? 'Completed' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: widget.task.isCompleted ? Colors.green : const Color(0xFFD4AF37),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                color: widget.task.isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                              child: Text(
                                widget.task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: widget.task.isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : (isOverdue ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                    ),
                                    const SizedBox(width: 4),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 300),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.task.isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : (isOverdue ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                        fontWeight: isOverdue && !widget.task.isCompleted ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      child: Text(DateFormat('MMM dd, yyyy').format(widget.task.date)),
                                    ),
                                  ],
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor().withOpacity(widget.task.isCompleted ? 0.05 : 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _getPriorityColor().withOpacity(widget.task.isCompleted ? 0.3 : 1.0)),
                                  ),
                                  child: Text(
                                    widget.task.priority,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _getPriorityColor().withOpacity(widget.task.isCompleted ? 0.5 : 1.0),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
