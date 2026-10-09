import '../models/label_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class DummyData {
  DummyData._();

  // Akun demo untuk tes login
  static const user = UserModel(id: 1, username: 'userpelajar');
  static const demoPassword = 'password123';

  static const labels = <LabelModel>[
    LabelModel(id: 1, userId: 1, namaLabel: 'Kalkulus', kodeWarna: '#8CB4FF'),
    LabelModel(id: 2, userId: 1, namaLabel: 'Struktur Data', kodeWarna: '#FFE066'),
    LabelModel(id: 3, userId: 1, namaLabel: 'Pemrograman Web', kodeWarna: '#FFB017'),
    LabelModel(id: 4, userId: 1, namaLabel: 'Sistem Operasi', kodeWarna: '#6BE86A'),
    LabelModel(id: 5, userId: 1, namaLabel: 'Project', kodeWarna: '#D4943A'),
    LabelModel(id: 6, userId: 1, namaLabel: 'Pribadi'), // tanpa warna
  ];

  // Tanggal relatif terhadap hari ini supaya level deadline selalu bervariasi.
  static DateTime _at(int days, int hour, int minute) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + days, hour, minute);
  }

  static final tasks = <TaskModel>[
    TaskModel(
      id: 1, userId: 1, labelId: 2,
      judul: 'Tugas Struktur Data',
      deskripsi: 'Kerjakan implementasi Quick Sort dan jelaskan proses partition.',
      deadline: _at(1, 23, 59),
      createdAt: _at(-1, 16, 30), updatedAt: _at(-1, 16, 30),
    ),
    TaskModel(
      id: 2, userId: 1, labelId: 5,
      judul: 'Prototype Mobile',
      deskripsi: 'Lengkapi flow dan pengujian usability untuk presentasi.',
      deadline: _at(3, 20, 0),
      createdAt: _at(-2, 9, 0), updatedAt: _at(-2, 9, 0),
    ),
    TaskModel(
      id: 3, userId: 1, labelId: 4,
      judul: 'Baca Bab 4',
      deskripsi: 'Catat poin penting manajemen memori.',
      deadline: _at(8, 17, 0),
      createdAt: _at(-3, 10, 15), updatedAt: _at(-3, 10, 15),
    ),
    TaskModel(
      id: 4, userId: 1, labelId: 1,
      judul: 'Latihan Turunan',
      deskripsi: 'Kerjakan latihan halaman 42.',
      deadline: _at(2, 18, 0),
      createdAt: _at(-3, 8, 0), updatedAt: _at(-3, 8, 0),
    ),
    TaskModel(
      id: 5, userId: 1, labelId: 1,
      judul: 'Kuis Kalkulus',
      deskripsi: 'Pelajari integral substitusi.',
      deadline: _at(5, 10, 0),
      createdAt: _at(-1, 11, 0), updatedAt: _at(-1, 11, 0),
    ),
    TaskModel(
      id: 6, userId: 1, labelId: 3,
      judul: 'Latihan Matriks',
      deskripsi: 'Selesaikan soal 1-15 dan unggah jawabannya.',
      deadline: _at(-2, 16, 20), isCompleted: true,
      createdAt: _at(-6, 9, 0), updatedAt: _at(-2, 16, 0),
    ),
    TaskModel(
      id: 7, userId: 1, labelId: 3,
      judul: 'Setup Repository',
      deskripsi: 'Buat struktur awal project web.',
      deadline: _at(-3, 15, 10), isCompleted: true,
      createdAt: _at(-7, 9, 0), updatedAt: _at(-3, 15, 0),
    ),
  ];
}