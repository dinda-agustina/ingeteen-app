import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/label_provider.dart';
import '../../providers/task_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/task_card.dart';
import '../task/task_detail_screen.dart';
import '../task/task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color navy = Color(0xFF26364D);
  static const Color cream = Color(0xFFF9F5E9);
  static const Color orange = Color(0xFFFFB31A);
  static const Color avatarBlue = Color(0xFF7FB3FF);
  static const Color lightCream = Color(0xFFF1ECDD);
  static const Color mutedText = Color(0xFF888888);

  int selectedTab = 0;
  bool _showUrgentOnly = false;

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  late final String greeting;

  @override
  void initState() {
    super.initState();
    greeting = _getGreeting();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TaskProvider>().loadTasks();
      context.read<LabelProvider>().loadLabels(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final day = DateTime.now().day;

    final List<String> greetings;

    if (hour >= 5 && hour < 12) {
      greetings = [
        'Good morning! Let’s make today productive.',
        'Rise and shine! Ready for a new day?',
        'Good morning! Start your day with a plan.',
      ];
    } else if (hour >= 12 && hour < 17) {
      greetings = [
        'Good afternoon! Keep up the good work.',
        'Hope your day is going well!',
        'Stay focused and keep making progress.',
      ];
    } else if (hour >= 17 && hour < 21) {
      greetings = [
        'Good evening! Finish your day strong.',
        'You are doing great. Keep going!',
        'A little progress today goes a long way.',
      ];
    } else {
      greetings = [
        'Working late? Remember to take a break.',
        'Plan tomorrow and get some rest.',
        'Every small step counts. Good night!',
      ];
    }

    return greetings[day % greetings.length];
  }

  Future<void> _openTaskForm({TaskModel? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
  }

  Future<void> _openTaskDetail(TaskModel task) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );

    if (!mounted || deleted != true) return;

    await _showTaskDeletedDialog();
  }

  Future<void> _showTaskDeletedDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4C9B63),
                    size: 23,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Task deleted!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF26364D),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Your task has been successfully deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB31A),
                      foregroundColor: const Color(0xFF26364D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final taskProvider = context.watch<TaskProvider>();
    final labelProvider = context.watch<LabelProvider>();

    final userLabels = user == null
        ? []
        : labelProvider.getLabelsForUser(user.id);

    final Map<int, Color> labelColorsById = {
      for (final label in userLabels) label.id: label.color,
    };

    final allTasks = taskProvider.tasks.where((task) {
      return user != null && task.userId == user.id;
    }).toList();

    final baseTabTasks = selectedTab == 0
        ? allTasks.where((task) => !task.isCompleted).toList()
        : allTasks.where((task) => task.isCompleted).toList();

    final tabTasks = _showUrgentOnly
        ? baseTabTasks
            .where((task) => task.deadlineLevel == DeadlineLevel.urgent)
            .toList()
        : baseTabTasks;

    final query = searchQuery.trim().toLowerCase();

    final filteredTasks = tabTasks.where((task) {
      final title = task.judul.toLowerCase();
      final description = task.deskripsi.toLowerCase();
      final label = (task.labelName ?? '').toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          label.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: cream,
      drawer: _buildDrawer(context, user?.username ?? 'User'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(Icons.menu, color: navy),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.username ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: avatarBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'US',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // SEARCH FIELD
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 19, color: mutedText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
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
                        style: const TextStyle(fontSize: 12, color: navy),
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
                          color: mutedText,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Organize your priorities and get things done.',
                style: TextStyle(fontSize: 10, color: mutedText),
              ),
              const SizedBox(height: 14),

              // PENDING AND COMPLETED TABS
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: lightCream,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTab('PENDING', 0)),
                    Expanded(child: _buildTab('COMPLETED', 1)),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // TASK LIST
              Expanded(
                child: taskProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : taskProvider.errorMessage != null
                        ? Center(
                            child: Text(taskProvider.errorMessage!),
                          )
                        : filteredTasks.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];

                                  return TaskCard(
                                    task: task,
                                    labelName: task.labelName?.trim() ?? '',
                                    labelColor: labelColorsById[task.labelId] ??
                                        const Color(0xFFE3DDD0),
                                    onChanged: () {
                                      context
                                          .read<TaskProvider>()
                                          .toggleTaskStatus(task.id);
                                    },
                                    onTap: () {
                                      _openTaskDetail(task);
                                    },
                                  );
                                },
                              )
                            : _buildEmptyState(
                                icon: _getEmptyIcon(
                                  searchQuery: searchQuery,
                                  selectedTab: selectedTab,
                                  allTasks: allTasks,
                                ),
                                title: _getEmptyTitle(
                                  searchQuery: searchQuery,
                                  selectedTab: selectedTab,
                                  allTasks: allTasks,
                                ),
                                message: _getEmptyMessage(
                                  searchQuery: searchQuery,
                                  selectedTab: selectedTab,
                                  allTasks: allTasks,
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),

      // ADD TASK BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        backgroundColor: orange,
        foregroundColor: navy,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _getEmptyIcon({
    required String searchQuery,
    required int selectedTab,
    required List<TaskModel> allTasks,
  }) {
    if (searchQuery.trim().isNotEmpty) {
      return Icons.search_off;
    }

    if (selectedTab == 1) {
      return Icons.task_alt;
    }

    if (allTasks.isEmpty) {
      return Icons.note_add_outlined;
    }

    return Icons.task_alt;
  }

  String _getEmptyTitle({
    required String searchQuery,
    required int selectedTab,
    required List<TaskModel> allTasks,
  }) {
    if (searchQuery.trim().isNotEmpty) {
      return 'No matching tasks';
    }

    if (selectedTab == 1) {
      return 'No completed tasks';
    }

    if (allTasks.isEmpty) {
      return 'No tasks yet';
    }

    return _showUrgentOnly ? 'No urgent tasks' : 'No pending tasks';
  }

  String _getEmptyMessage({
    required String searchQuery,
    required int selectedTab,
    required List<TaskModel> allTasks,
  }) {
    if (searchQuery.trim().isNotEmpty) {
      return 'Try another keyword to find your task.';
    }

    if (selectedTab == 1) {
      return 'Your completed tasks will appear here.';
    }

    if (allTasks.isEmpty) {
      return 'Your task list is empty. Add your first task and start organizing your day.';
    }

    return _showUrgentOnly
        ? 'You do not have any urgent tasks right now.'
        : 'You have no pending tasks right now.';
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: lightCream,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: navy),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          _showUrgentOnly = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: selected ? Border.all(color: orange, width: 1.2) : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: selected ? navy : mutedText,
            ),
          ),
        ),
      ),
    );
  }

  // NAVIGATION DRAWER
  Widget _buildDrawer(BuildContext context, String username) {
    const selectedBackground = Color(0xFFFFE8B0);

    Widget menuItem(
      IconData icon,
      String title, {
      bool selected = false,
      VoidCallback? onTap,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(icon, color: navy, size: 20),
          title: Text(
            title,
            style: TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap ??
              () {
                Navigator.pop(context);

                if (title == 'Labels') {
                  Navigator.pushNamed(context, AppRoutes.label);
                } else if (title == 'Urgent') {
                  setState(() {
                    selectedTab = 0;
                    _showUrgentOnly = true;
                  });
                } else if (title == 'All Tasks') {
                  setState(() {
                    selectedTab = 0;
                    _showUrgentOnly = false;
                  });
                }
              },
        ),
      );
    }

    return Drawer(
      backgroundColor: cream,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(fontSize: 16),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  menuItem(
                    Icons.description_outlined,
                    'All Tasks',
                    selected: !_showUrgentOnly,
                  ),
                  menuItem(
                    Icons.checklist,
                    'Urgent',
                    selected: _showUrgentOnly,
                  ),
                  menuItem(
                    Icons.label_outline,
                    'Labels',
                  ),
                  menuItem(
                    Icons.archive_outlined,
                    'Archive',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.archive);
                    },
                  ),
                  menuItem(
                    Icons.delete_outline,
                    'Trash',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.trash);
                    },
                  ),
                ],
              ),
            ),

            // PROFILE AND LOGOUT
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: avatarBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'US',
                          style: TextStyle(
                            color: navy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Profile Settings',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Log out',
                      onPressed: () {
                        context.read<AuthProvider>().logout();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (_) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: navy,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}