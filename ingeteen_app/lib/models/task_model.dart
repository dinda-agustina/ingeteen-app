enum DeadlineLevel { urgent, near, safe }

class TaskModel {
  final int id;
  final int userId;
  final int? labelId;
  final String? labelName;
  final String judul;
  final String deskripsi;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    this.labelId,
    this.labelName,
    required this.judul,
    required this.deskripsi,
    required this.deadline,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DeadlineLevel get deadlineLevel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    final days = due.difference(today).inDays;

    if (days <= 1) return DeadlineLevel.urgent;
    if (days <= 3) return DeadlineLevel.near;
    return DeadlineLevel.safe;
  }

  TaskModel copyWith({
    int? labelId,
    String? labelName,
    bool clearLabel = false,
    String? judul,
    String? deskripsi,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      labelId: clearLabel ? null : (labelId ?? this.labelId),
      labelName: clearLabel ? null : (labelName ?? this.labelName),
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      userId: json['user_id'],
      labelId: json['label_id'],
      labelName: json['label_name'],
      judul: json['judul'],
      deskripsi: json['deskripsi'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['is_completed'] == true ||
          json['is_completed'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label_id': labelId,
      'label_name': labelName,
      'judul': judul,
      'deskripsi': deskripsi,
      'deadline': deadline.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}