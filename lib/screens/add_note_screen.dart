import 'package:flutter/material.dart';

import '../data/dummy_notes.dart';
import '../models/note.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;

  const AddNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final List<String> _labels = [
    'Catatan Kuliah',
    'Struktur Data',
    'Pemrograman',
    'Sistem Operasi',
    'Project',
    'Lainnya',
  ];

  String? _selectedLabel;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;

      if (_labels.contains(note.label)) {
        _selectedLabel = note.label;
      } else {
        _labels.add(note.label);
        _selectedLabel = note.label;
      }
    } else {
      _selectedLabel = _labels.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori catatan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (_isEditing) {
      final note = widget.note!;

      note.title = _titleController.text.trim();
      note.content = _contentController.text.trim();
      note.label = _selectedLabel!;
    } else {
      dummyNotes.add(
        Note(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          label: _selectedLabel!,
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
          _isEditing ? 'Edit Catatan' : 'Catatan Baru',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveNote,
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
            _fieldLabel('Judul Catatan'),
            TextFormField(
              controller: _titleController,
              decoration: _inputDecoration(
                'Masukkan judul catatan',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul catatan wajib diisi.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            _fieldLabel('Kategori'),
            DropdownButtonFormField<String>(
              initialValue: _selectedLabel,
              decoration: _inputDecoration(
                'Pilih kategori catatan',
              ),
              items: _labels.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Pilih kategori catatan terlebih dahulu.';
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

            _fieldLabel('Isi Catatan'),
            TextFormField(
              controller: _contentController,
              minLines: 8,
              maxLines: 12,
              textAlignVertical: TextAlignVertical.top,
              decoration: _inputDecoration(
                'Tuliskan catatan kamu di sini...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi catatan wajib diisi.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveNote,
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
                    : 'Simpan Catatan',
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
}