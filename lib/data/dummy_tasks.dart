import '../models/task.dart';

final List<Task> dummyTasks = [
  Task(
    title: 'Tugas Struktur Data',
    description:
        'Kerjakan implementasi Quick Sort dan jelaskan proses partisi.',
    priority: 'Urgent - Tomorrow',
    label: 'Struktur Data',
    deadline: 'Oct 3, 2026 • 11:59 PM',
    completed: false,
  ),
  Task(
    title: 'Prototype Mobile',
    description:
        'Lengkapi flow dan pengujian usability untuk prototype.',
    priority: 'Moderate Deadline',
    label: 'Project',
    deadline: 'Oct 5, 2026 • 8:00 PM',
    completed: false,
  ),
  Task(
    title: 'Baca Bab 4',
    description:
        'Catat poin penting mengenai manajemen memori.',
    priority: 'Low Priority',
    label: 'Sistem Operasi',
    deadline: 'Oct 10, 2026 • 5:00 PM',
    completed: false,
  ),
  Task(
    title: 'Latihan Matriks',
    description:
        'Selesaikan latihan matriks dan kumpulkan hasilnya.',
    priority: 'Low Priority',
    label: 'Kalkulus',
    deadline: 'Oct 1, 2026 • 6:00 PM',
    completed: true,
  ),
];