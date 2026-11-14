import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task.dart';
import '../../providers/auth_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/task_card.dart';
import '../add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  final TextEditingController _searchController =
      TextEditingController();

  List<Task> tasks = <Task>[];

  String searchQuery = '';

  bool isLoading = true;
  bool isBusy = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOAD TASKS
  // ==========================================

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final List<Task> loadedTasks =
          await TaskService.getTasks();

      if (!mounted) return;

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load tasks. Please try again.';
      });
    }
  }

  // ==========================================
  // ADD TASK
  // ==========================================

  Future<void> _openAddTask() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            const AddTaskScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadTasks();
    }
  }

  // ==========================================
  // EDIT TASK
  // ==========================================

  Future<void> _openEditTask(Task task) async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            AddTaskScreen(task: task),
      ),
    );

    if (result == true && mounted) {
      await _loadTasks();
    }
  }

  // ==========================================
  // UPDATE TASK COMPLETION
  // ==========================================

  Future<void> _toggleTask(Task task) async {
    if (isBusy) return;

    final bool previousValue = task.completed;

    setState(() {
      isBusy = true;
      task.completed = !previousValue;
    });

    try {
      await TaskService.updateTask(task);

      if (!mounted) return;

      setState(() {
        isBusy = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        task.completed = previousValue;
        isBusy = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update task.'),
        ),
      );
    }
  }

  // ==========================================
  // DELETE TASK
  // ==========================================

  Future<void> _deleteTask(Task task) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text(
            'Are you sure you want to delete "${task.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await TaskService.deleteTask(task.id);

      if (!mounted) return;

      setState(() {
        tasks.removeWhere(
          (Task item) => item.id == task.id,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete task.'),
        ),
      );
    }
  }

  // ==========================================
  // PARSE DEADLINE
  // ==========================================

  DateTime _parseDeadline(String value) {
    try {
      final String normalized = value
          .replaceAll('Ã¢â‚¬Â¢', '•')
          .replaceAll('â€¢', '•')
          .replaceAll('Â·', '•');

      final List<String> parts = normalized.split('•');

      if (parts.length != 2) {
        return DateTime(2100);
      }

      final String dateString = parts[0].trim();
      final String timeString = parts[1].trim();

      final List<String> dateParts =
          dateString.split(RegExp(r'\s+'));

      final List<String> timeParts =
          timeString.split(':');

      if (dateParts.length != 3 ||
          timeParts.length != 2) {
        return DateTime(2100);
      }

      // English and Indonesian month names.
      const Map<String, int> months = {
        'january': 1,
        'jan': 1,
        'february': 2,
        'feb': 2,
        'march': 3,
        'mar': 3,
        'april': 4,
        'apr': 4,
        'may': 5,
        'mei': 5,
        'june': 6,
        'jun': 6,
        'juni': 6,
        'july': 7,
        'jul': 7,
        'juli': 7,
        'august': 8,
        'aug': 8,
        'agustus': 8,
        'september': 9,
        'sep': 9,
        'october': 10,
        'oct': 10,
        'oktober': 10,
        'november': 11,
        'nov': 11,
        'december': 12,
        'dec': 12,
        'desember': 12,
      };

      final int day = int.parse(dateParts[0]);

      final int? month =
          months[dateParts[1].toLowerCase()];

      final int year = int.parse(dateParts[2]);

      if (month == null) {
        return DateTime(2100);
      }

      final int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      if (hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return DateTime(2100);
      }

      final DateTime date = DateTime(
        year,
        month,
        day,
        hour,
        minute,
      );

      // Validate date.
      if (date.year != year ||
          date.month != month ||
          date.day != day) {
        return DateTime(2100);
      }

      return date;
    } catch (_) {
      return DateTime(2100);
    }
  }

  // ==========================================
  // FILTER AND SORT TASKS
  // ==========================================

  List<Task> _getDisplayedTasks() {
    final String query = searchQuery.toLowerCase();

    final List<Task> filteredTasks =
        tasks.where((Task task) {
      // Filter by selected tab.
      final bool matchesTab = selectedTab == 0
          ? !task.completed
          : task.completed;

      // Filter by search query.
      final bool matchesSearch =
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.label.toLowerCase().contains(query);

      return matchesTab && matchesSearch;
    }).toList();

    // Sort tasks by nearest deadline.
    filteredTasks.sort(
      (Task a, Task b) {
        return _parseDeadline(a.deadline).compareTo(
          _parseDeadline(b.deadline),
        );
      },
    );

    return filteredTasks;
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider =
        context.watch<AuthProvider>();

    final String username =
        authProvider.user?.username ?? 'User';

    final List<Task> pendingTasks = tasks
        .where((Task task) => !task.completed)
        .toList();

    final List<Task> completedTasks = tasks
        .where((Task task) => task.completed)
        .toList();

    final List<Task> displayedTasks =
        _getDisplayedTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header.
              _buildHeader(username),

              const SizedBox(height: 18),

              // Search bar.
              _buildSearchBar(),

              const SizedBox(height: 20),

              // Tasks heading.
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26364D),
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Set your priorities and complete them one by one.',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF888888),
                ),
              ),

              const SizedBox(height: 14),

              // Pending and Completed tabs.
              _buildTabs(
                pendingCount: pendingTasks.length,
                completedCount: completedTasks.length,
              ),

              const SizedBox(height: 14),

              // Task list.
              Expanded(
                child: _buildTaskList(displayedTasks),
              ),
            ],
          ),
        ),
      ),

      // Add task button.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : _openAddTask,
        backgroundColor: const Color(0xFFFFB31A),
        foregroundColor: const Color(0xFF26364D),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================

  Widget _buildHeader(String username) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $username!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26364D),
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Stay productive today!',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF7FB3FF),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'US',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26364D),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SEARCH BAR
  // ==========================================

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 19,
            color: Color(0xFF888888),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (String value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),

          if (searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();

                setState(() {
                  searchQuery = '';
                });
              },
              icon: const Icon(
                Icons.close,
                size: 17,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // TABS
  // ==========================================

  Widget _buildTabs({
    required int pendingCount,
    required int completedCount,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECDD),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              'PENDING',
              0,
              pendingCount,
            ),
          ),

          Expanded(
            child: _buildTab(
              'COMPLETED',
              1,
              completedCount,
            ),
          ),
        ],
      ),
    );
  }

  // Individual tab.
  Widget _buildTab(
    String title,
    int index,
    int count,
  ) {
    final bool selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: selected
              ? Border.all(
                  color: const Color(0xFFFFB31A),
                )
              : null,
        ),
        child: Center(
          child: Text(
            '$title ($count)',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: selected
                  ? const Color(0xFF26364D)
                  : const Color(0xFF8A8A8A),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TASK LIST
  // ==========================================

  Widget _buildTaskList(List<Task> displayedTasks) {
    // Loading indicator.
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFB31A),
        ),
      );
    }

    // Error state.
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state.
    if (displayedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.assignment_outlined,
              size: 45,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 10),

            Text(
              searchQuery.isNotEmpty
                  ? 'No tasks found.'
                  : selectedTab == 0
                      ? 'No pending tasks.'
                      : 'No completed tasks.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      );
    }

    // Display tasks.
    return ListView.builder(
      itemCount: displayedTasks.length,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final Task task = displayedTasks[index];

        return TaskCard(
          task: task,

          onChanged: () {
            _toggleTask(task);
          },

          onEdit: () {
            _openEditTask(task);
          },

          onDelete: () {
            _deleteTask(task);
          },
        );
      },
    );
  }
}