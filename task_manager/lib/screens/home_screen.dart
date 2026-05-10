import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../widgets/task_card.dart';
import '../widgets/quote_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_task_screen.dart';
import 'profile_screen.dart';
import '../models/task_model.dart';
import '../providers/theme_provider.dart';
import '../utils/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = "";
  String _filter = "All"; 
  late ScrollController _scrollController;
  bool _isFabVisible = true;
  Key _quoteKey = UniqueKey();

  Future<void> _handleRefresh() async {
    setState(() {
      _quoteKey = UniqueKey();
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_isFabVisible) setState(() => _isFabVisible = false);
      }
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_isFabVisible) setState(() => _isFabVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    return fullName.split(' ')[0];
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'U';
    return fullName.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final taskService = Provider.of<TaskService>(context);
    final user = authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF0B0B0B), const Color(0xFF161616), const Color(0xFF0B0B0B)]
                : [const Color(0xFFFFF8E7), const Color(0xFFF7F1E3), const Color(0xFFFFF8E7)],
          ),
        ),
        child: StreamBuilder<List<TaskModel>>(
          stream: taskService.getTasks(user?.uid ?? ''),
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? [];
            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: FlexibleSpaceBar(
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    _getInitials(user?.displayName),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hi, ${_getFirstName(user?.displayName)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return IconButton(
                          icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () => themeProvider.toggleTheme(),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).push(
                        PageTransitions.fadeScaleRoute(const ProfileScreen()),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Column(
                      children: [
                        QuoteCard(key: _quoteKey),
                        _buildStatsBar(tasks, isDark),
                        _buildSearchBar(isDark),
                        _buildFilterChips(isDark),
                      ],
                    ),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (tasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      onAddPressed: () => Navigator.of(context).push(
                        PageTransitions.slideUpRoute(const AddEditTaskScreen()),
                      ),
                    ),
                  )
                else
                  _buildTaskList(tasks, taskService),
              ],
            ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: FloatingActionButton.extended(
          heroTag: 'fab_add_task',
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          onPressed: () => Navigator.of(context).push(
            PageTransitions.slideUpRoute(const AddEditTaskScreen()),
          ),
          label: const Text('New Task', style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatsBar(List<TaskModel> tasks, bool isDark) {
    int total = tasks.length;
    int done = tasks.where((t) => t.isCompleted).length;
    int pending = total - done;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black : Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : Colors.white.withOpacity(0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('Total', total.toString(), Icons.fact_check_outlined, isDark ? Colors.white : Colors.black87),
                Container(height: 40, width: 1, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
                _statItem('Pending', pending.toString(), Icons.pending_actions, Theme.of(context).colorScheme.secondary),
                Container(height: 40, width: 1, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
                _statItem('Done', done.toString(), Icons.check_circle_outline, Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              hintText: 'Search tasks...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : Colors.white.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.black.withOpacity(0.05)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: ["All", "Pending", "Completed"].map((f) {
            final isSelected = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : (isDark ? const Color(0xFF1E1E1E).withOpacity(0.5) : Colors.white.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : (isDark ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.black.withOpacity(0.05))
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                    ] : [],
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> allTasks, TaskService taskService) {
    var filteredTasks = allTasks;

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks.where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_filter == "Pending") {
      filteredTasks = filteredTasks.where((t) => !t.isCompleted).toList();
    } else if (_filter == "Completed") {
      filteredTasks = filteredTasks.where((t) => t.isCompleted).toList();
    }

    if (filteredTasks.isEmpty) {
      return SliverFillRemaining(
        child: Center(child: Text('No matching tasks found.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final task = filteredTasks[index];
            return TweenAnimationBuilder<double>(
              key: ValueKey(task.id),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 400)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  await taskService.deleteTask(task.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => taskService.addTask(task),
                        ),
                      ),
                    );
                  }
                },
                child: TaskCard(
                  task: task,
                  onTap: () => Navigator.of(context).push(
                    PageTransitions.slideUpRoute(AddEditTaskScreen(task: task)),
                  ),
                  onToggle: (val) => taskService.toggleTaskStatus(task.id, val ?? false),
                ),
              ),
            );
          },
          childCount: filteredTasks.length,
        ),
      ),
    );
  }
}
