
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/dummy_tasks.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../widgets/task_card.dart';
import '../../search_tasks_screen.dart';

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
                          'Semangat untuk hari ini!',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF26364D),
                    ),
                    onSelected: (value) {
                      if (value == 'logout') {
                        context.read<AuthProvider>().logout();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (_) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18),
                            SizedBox(width: 8),
                            Text('Keluar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
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
                          'Cari tugas...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Tugas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26364D),
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'Atur prioritas dan tuntaskan satu per satu.',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF888888),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECDD),
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

              Expanded(
                child: displayedTasks.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada tugas pada kategori ini.',
                          style: TextStyle(
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
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fitur tambah tugas belum tersedia.',
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFFFFB31A),
        foregroundColor: const Color(0xFF26364D),
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
            title,
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
}