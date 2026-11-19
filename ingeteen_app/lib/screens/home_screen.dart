import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // IngeTeen color palette.
  static const navy = Color(0xFF26364D);
  static const cream = Color(0xFFF9F5E9);
  static const orange = Color(0xFFFFB31A);
  static const avatarBlue = Color(0xFF7FB3FF);
  static const lightCream = Color(0xFFF1ECDD);
  static const mutedText = Color(0xFF888888);

  int selectedTab = 0;

  final TextEditingController _searchController =
      TextEditingController();

  String searchQuery = '';

  late final String greeting;

  @override
  void initState() {
    super.initState();
    greeting = _getGreeting();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Greeting based on current time and day.
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

  // Open Add Task or Edit Task form.
  Future<void> _openTaskForm({TaskModel? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );
  }

  // Open Task Detail page.
  Future<void> _openTaskDetail(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final taskProvider = context.watch<TaskProvider>();

    final allTasks = taskProvider.tasks;

    // Select tasks based on the active tab.
    final tabTasks = selectedTab == 0
        ? taskProvider.pendingTasks
        : taskProvider.completedTasks;

    final query = searchQuery.trim().toLowerCase();

    // Search by title, description, and label.
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

      drawer: _buildDrawer(
        context,
        user?.username ?? 'User',
      ),

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
              Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: navy,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
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

              // Search field.
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
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
                    const Icon(
                      Icons.search,
                      size: 19,
                      color: mutedText,
                    ),

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
                        style: const TextStyle(
                          fontSize: 12,
                          color: navy,
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
                style: TextStyle(
                  fontSize: 10,
                  color: mutedText,
                ),
              ),

              const SizedBox(height: 14),

              // Pending and Completed tabs.
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: lightCream,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab('PENDING', 0),
                    ),
                    Expanded(
                      child: _buildTab('COMPLETED', 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Task list and empty states.
              Expanded(
                child: filteredTasks.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];

                          return TaskCard(
                            task: task,
                            labelName:
                                task.labelName?.trim() ?? '',
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
                        icon: searchQuery.trim().isNotEmpty
                            ? Icons.search_off
                            : selectedTab == 1
                                ? Icons.task_alt
                                : allTasks.isEmpty
                                    ? Icons.note_add_outlined
                                    : Icons.task_alt,
                        title: searchQuery.trim().isNotEmpty
                            ? 'No matching tasks'
                            : selectedTab == 1
                                ? 'No completed tasks'
                                : allTasks.isEmpty
                                    ? 'No tasks yet'
                                    : 'No pending tasks',
                        message: searchQuery.trim().isNotEmpty
                            ? 'Try another keyword to find your task.'
                            : selectedTab == 1
                                ? 'Your completed tasks will appear here.'
                                : allTasks.isEmpty
                                    ? 'Your task list is empty. Add your first task and start organizing your day.'
                                    : 'You have no pending tasks right now.',
                      ),
              ),
            ],
          ),
        ),
      ),

      // Add Task button.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(),
        backgroundColor: orange,
        foregroundColor: navy,
        elevation: 2,
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

  // Empty state.
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
              child: Icon(
                icon,
                size: 52,
                color: navy,
              ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
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

  // Tab button.
  Widget _buildTab(String title, int index) {
    final selected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: selected
              ? Border.all(
                  color: orange,
                  width: 1.2,
                )
              : null,
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

  // Navigation drawer.
  Widget _buildDrawer(
    BuildContext context,
    String username,
  ) {
    const selectedBackground = Color(0xFFFFE8B0);

    Widget menuItem(
      IconData icon,
      String title, {
      bool selected = false,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected
              ? selectedBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          leading: Icon(
            icon,
            color: navy,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      );
    }

    return Drawer(
      backgroundColor: cream,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                24,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_note,
                        color: navy,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'Inge',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Teen',
                    style: TextStyle(
                      color: navy,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                children: [
                  menuItem(
                    Icons.description_outlined,
                    'All Tasks',
                    selected: true,
                  ),
                  menuItem(
                    Icons.checklist,
                    'Urgent',
                  ),
                  menuItem(
                    Icons.label_outline,
                    'Labels',
                  ),
                  menuItem(
                    Icons.inventory_2_outlined,
                    'Archive',
                  ),
                  menuItem(
                    Icons.delete_outline,
                    'Trash',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                20,
              ),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                        context
                            .read<AuthProvider>()
                            .logout();

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