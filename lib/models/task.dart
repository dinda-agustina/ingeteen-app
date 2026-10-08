class Task {
  final String title;
  final String description;
  final String priority;
  final String label;
  final String deadline;
  bool completed;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    required this.label,
    required this.deadline,
    this.completed = false,
  });
}