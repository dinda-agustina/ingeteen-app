import 'package:flutter/material.dart';

import 'data/dummy_tasks.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({super.key});

  @override
  State<SearchTasksScreen> createState() =>
      _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<Task> get filteredTasks {
    final keyword =
        searchController.text.trim().toLowerCase();

    if (keyword.isEmpty) {
      return [];
    }

    return dummyTasks.where((task) {
      return task.title.toLowerCase().contains(keyword) ||
          task.description.toLowerCase().contains(keyword) ||
          task.priority.toLowerCase().contains(keyword) ||
          task.label.toLowerCase().contains(keyword) ||
          task.deadline.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5E9),
        foregroundColor: const Color(0xFF26364D),
        elevation: 0,
        title: const Text(
          'Search Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              autofocus: true,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searchController.text.trim().isEmpty
                  ? 'Enter a keyword to search for tasks.'
                  : '${results.length} tasks found',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: searchController.text.trim().isEmpty
                  ? const Center(
                      child: Text(
                        'Search by task title, description, '
                        'course, or deadline.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888888),
                        ),
                      ),
                    )
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            'No tasks found.',
                            style: TextStyle(
                              color: Color(0xFF888888),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final task = results[index];

                            return TaskCard(
                              task: task,
                              onChanged: () {
                                setState(() {
                                  task.completed =
                                      !task.completed;
                                });
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}