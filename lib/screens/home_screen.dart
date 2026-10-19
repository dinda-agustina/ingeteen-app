import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_tasks.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../widgets/task_card.dart';
import '../search_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    final pendingTasks =
        dummyTasks.where((task) => !task.completed).toList();

    final completedTasks =
        dummyTasks.where((task) => task.completed).toList();

    final displayedTasks =
        selectedTab == 0 ? pendingTasks : completedTasks;

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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.username ?? 'User'}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF26364D),
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Stay focused and make today count!',
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
              ),
              const SizedBox(height: 14),

              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SearchTasksScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 42,
                  width: double.infinity,
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 18,
                        color: Color(0xFF888888),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Search tasks...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Task List',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26364D),
                      ),
                    ),
                  ),
                  Text(
                    '${displayedTasks.length} tasks',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTab(
                      title: 'All Tasks',
                      isSelected: selectedTab == 0,
                      onTap: () {
                        setState(() {
                          selectedTab = 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTab(
                      title: 'Completed',
                      isSelected: selectedTab == 1,
                      onTap: () {
                        setState(() {
                          selectedTab = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Expanded(
                child: displayedTasks.isEmpty
                    ? Center(
                        child: Text(
                          selectedTab == 0
                              ? 'No pending tasks.'
                              : 'No completed tasks yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedTasks.length,
                        itemBuilder: (context, index) {
                          final task = displayedTasks[index];

                          return TaskCard(
                            task: task,
                            onChanged: () {
                              setState(() {
                                task.completed = !task.completed;
                              });
                            },
                          );
                        },
                      ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().logout();

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Log out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF26364D)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : const Color(0xFF26364D),
          ),
        ),
      ),
    );
  }
}