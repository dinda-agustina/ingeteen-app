import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskService {
  TaskService._();

  static const String _tasksKey = 'ingeteen_tasks';

  static Future<List<Task>> getTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_tasksKey);

    if (savedData == null || savedData.isEmpty) {
      return <Task>[];
    }

    final dynamic decoded = jsonDecode(savedData);

    if (decoded is! List) {
      throw const FormatException('Invalid task data format.');
    }

    final List<Task> tasks = decoded.map<Task>((dynamic item) {
      if (item is! Map) {
        throw const FormatException('Invalid task item.');
      }

      return Task.fromJson(Map<String, dynamic>.from(item));
    }).toList();

    final Set<String> ids = tasks.map((Task task) => task.id).toSet();

    if (ids.length != tasks.length) {
      throw const FormatException('Duplicate task IDs detected.');
    }

    return tasks;
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final Set<String> ids = tasks.map((Task task) => task.id).toSet();

    if (ids.length != tasks.length) {
      throw ArgumentError('Task IDs must be unique.');
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      tasks.map((Task task) => task.toJson()).toList(),
    );

    final bool success = await prefs.setString(_tasksKey, encoded);

    if (!success) {
      throw Exception('Failed to save tasks.');
    }
  }

  static Future<void> addTask(Task task) async {
    final List<Task> tasks = await getTasks();

    if (tasks.any((Task item) => item.id == task.id)) {
      throw Exception('Task ID already exists.');
    }

    tasks.add(task);

    await saveTasks(tasks);
  }

  static Future<void> updateTask(Task updatedTask) async {
    final List<Task> tasks = await getTasks();

    final int index = tasks.indexWhere(
      (Task task) => task.id == updatedTask.id,
    );

    if (index == -1) {
      throw Exception('Task not found.');
    }

    tasks[index] = updatedTask;

    await saveTasks(tasks);
  }

  static Future<void> deleteTask(String id) async {
    final List<Task> tasks = await getTasks();

    final int index = tasks.indexWhere((Task task) => task.id == id);

    if (index == -1) {
      throw Exception('Task not found.');
    }

    tasks.removeAt(index);

    await saveTasks(tasks);
  }

  static Future<void> clearTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tasksKey);
  }
}
