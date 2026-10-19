class Task {
  String title;
  String description;
  String priority;
  String label;
  String deadline;
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