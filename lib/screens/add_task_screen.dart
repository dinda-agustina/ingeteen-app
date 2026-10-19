import 'package:flutter/material.dart';

import '../data/dummy_tasks.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({
    super.key,
    this.task,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _labels = [
    'Struktur Data',
    'Pemrograman',
    'Sistem Operasi',
    'Project',
    'Lainnya',
  ];

  String? _selectedLabel;

  DateTime _deadline = DateTime.now().add(
    const Duration(days: 1),
  );

  TimeOfDay _time = const TimeOfDay(
    hour: 23,
    minute: 59,
  );

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;

      if (_labels.contains(task.label)) {
        _selectedLabel = task.label;
      } else {
        _labels.add(task.label);
        _selectedLabel = task.label;
      }

      _restoreDeadline(task.deadline);
    }
  }

  void _restoreDeadline(String value) {
    try {
      final parts = value.split(' • ');

      if (parts.length != 2) return;

      final dateParts = parts[0].split(' ');

      if (dateParts.length != 3) return;

      const months = {
        'Januari': 1,
        'Februari': 2,
        'Maret': 3,
        'April': 4,
        'Mei': 5,
        'Juni': 6,
        'Juli': 7,
        'Agustus': 8,
        'September': 9,
        'Oktober': 10,
        'November': 11,
        'Desember': 12,
      };

      final day = int.parse(dateParts[0]);
      final month = months[dateParts[1]];
      final year = int.parse(dateParts[2]);

      if (month == null) return;

      final date = DateTime(year, month, day);
      final timeParts = parts[1].split(':');

      if (timeParts.length != 2) return;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return;
      }

      _deadline = date;
      _time = TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      // Pengguna tetap dapat memilih tanggal dan waktu baru.
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null && mounted) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih label tugas terlebih dahulu.'),
        ),
      );
      return;
    }

    final deadline =
        '${_formatDate(_deadline)} • ${_formatTime(_time)}';

    if (_isEditing) {
      final task = widget.task!;

      task.title = _titleController.text.trim();
      task.description = _descriptionController.text.trim();
      task.label = _selectedLabel!;
      task.deadline = deadline;
    } else {
      dummyTasks.add(
        Task(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: 'Moderate Deadline',
          label: _selectedLabel!,
          deadline: deadline,
        ),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF26364D);
    const orange = Color(0xFFFFAD16);
    const background = Color(0xFFF9F5E9);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: navy,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Tugas' : 'Tugas Baru',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _fieldLabel('Judul Tugas'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                'Masukkan judul tugas',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tugas wajib diisi.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            _fieldLabel('Deskripsi'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Jelaskan tugas yang harus dikerjakan...',
              ),
            ),
            const SizedBox(height: 16),

            _fieldLabel('Label'),
            DropdownButtonFormField<String>(
              initialValue: _selectedLabel,
              decoration: _inputDecoration('Pilih label'),
              items: _labels.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Pilih label tugas terlebih dahulu.';
                }

                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedLabel = value;
                });
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Tanggal Pengumpulan'),
                      OutlinedButton(
                        onPressed: _pickDate,
                        style: _outlineStyle(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(_deadline),
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Waktu Pengumpulan'),
                      OutlinedButton(
                        onPressed: _pickTime,
                        style: _outlineStyle(),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatTime(_time),
                                style: const TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: navy,
                minimumSize: const Size(
                  double.infinity,
                  46,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isEditing
                    ? 'Simpan Perubahan'
                    : 'Simpan Tugas',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF26364D),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE4E1D8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFFFAD16),
          width: 1.5,
        ),
      ),
    );
  }

  ButtonStyle _outlineStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF26364D),
      backgroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 42),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      side: const BorderSide(
        color: Color(0xFFE4E1D8),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}