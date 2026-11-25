
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

  // Status Archive dan Trash dari Laravel.
  final DateTime? archivedAt;
  final DateTime? deletedAt;

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
    this.archivedAt,
    this.deletedAt,
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

    // Tambahan untuk Archive dan Trash.
    DateTime? archivedAt,
    DateTime? deletedAt,
    bool clearArchivedAt = false,
    bool clearDeletedAt = false,
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

      // Mempertahankan atau menghapus status Archive dan Trash.
      archivedAt: clearArchivedAt
          ? null
          : (archivedAt ?? this.archivedAt),

      deletedAt: clearDeletedAt
          ? null
          : (deletedAt ?? this.deletedAt),
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

      // Membaca status Archive dan Trash dari response Laravel.
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'].toString())
          : null,

      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
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
      'archived_at': archivedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
