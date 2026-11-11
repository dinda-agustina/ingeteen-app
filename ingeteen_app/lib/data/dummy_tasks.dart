import '../models/task.dart';

final List<Task> dummyTasks = [
  Task(
    title: 'Tugas Struktur Data',
    description:
        'Kerjakan implementasi Quick Sort dan jelaskan proses partisi.',
    priority: 'Urgent - Besok',
    label: 'Struktur Data',
    deadline: '3 Okt 2026 • 23:59',
    completed: false,
  ),

  Task(
    title: 'Prototype Mobile',
    description:
        'Lengkapi flow dan pengujian usability untuk prototype.',
    priority: 'Moderate deadline',
    label: 'Project',
    deadline: '5 Okt 2026 • 20:00',
    completed: false,
  ),

  Task(
    title: 'Baca Bab 4',
    description:
        'Catat poin penting mengenai manajemen memori.',
    priority: 'Aman',
    label: 'Sistem Operasi',
    deadline: '10 Okt 2026 • 17:00',
    completed: false,
  ),

  Task(
    title: 'Latihan Matriks',
    description:
        'Selesaikan latihan matriks dan kumpulkan hasilnya.',
    priority: 'Completed',
    label: 'Kalkulus',
    deadline: '1 Okt 2026 • 18:00',
    completed: true,
  ),
];