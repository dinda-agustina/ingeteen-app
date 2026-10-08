enum DeadlineLevel { urgent, near, safe }

class TaskModel {
  final int id;
  final int userId;
  final int? labelId;
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
    required this.judul,
    required this.deskripsi,
    required this.deadline,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Urgent: besok atau sudah terlewat. Mendekati: <= 3 hari. Selebihnya Aman.
  DeadlineLevel get deadlineLevel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(deadline.year, deadline.month, deadline.day);
    final days = due.difference(today).inDays;
    if (days <= 1) return DeadlineLevel.urgent;
    if (days <= 3) return DeadlineLevel.near;
    return DeadlineLevel.safe;
  }

  /// [clearLabel] = true untuk mengosongkan label (labelId jadi null).
  TaskModel copyWith({
    int? labelId,
    bool clearLabel = false,
    String? judul,
    String? deskripsi,
    DateTime? deadline,
    bool? isCompleted,
  }) =>
      TaskModel(
        id: id,
        userId: userId,
        labelId: clearLabel ? null : (labelId ?? this.labelId),
        judul: judul ?? this.judul,
        deskripsi: deskripsi ?? this.deskripsi,
        deadline: deadline ?? this.deadline,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        userId: json['user_id'],
        labelId: json['label_id'],
        judul: json['judul'],
        deskripsi: json['deskripsi'] ?? '',
        deadline: DateTime.parse(json['deadline']),
        isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'label_id': labelId,
        'judul': judul,
        'deskripsi': deskripsi,
        'deadline': deadline.toIso8601String(),
        'is_completed': isCompleted,
      };
}