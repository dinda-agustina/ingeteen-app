class Task {
  final String id;
  String title;
  String description;
  String priority;
  String label;
  String deadline;
  bool completed;

  Task({
    String? id,
    required this.title,
    required this.description,
    required this.priority,
    required this.label,
    required this.deadline,
    this.completed = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Moderate Deadline',
      label: json['label'] as String? ?? 'Others',
      deadline: json['deadline'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'label': label,
      'deadline': deadline,
      'completed': completed,
    };
  }
}
