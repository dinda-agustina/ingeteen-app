import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/label_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/label_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import 'label_create_screen.dart';

class LabelScreen extends StatelessWidget {
  const LabelScreen({super.key});

  static const Color _background = Color(0xFFFAF8F1);
  static const Color _navy = Color(0xFF101C3C);
  static const Color _orange = Color(0xFFFFA800);
  static const Color _grey = Color(0xFF8C8C8C);

  // Menghitung jumlah tugas pada sebuah label.
  int _getTaskCount(List<TaskModel> tasks, int labelId) {
    return tasks.where((task) => task.labelId == labelId).length;
  }

  // Popup berhasil atau gagal.
  Future<void> _showStatusDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool isSuccess = true,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? const Color(0xFFE6F4E9)
                        : const Color(0xFFFFE9E9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_rounded : Icons.close_rounded,
                    color: isSuccess
                        ? const Color(0xFF4C9B63)
                        : Colors.redAccent,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: _navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Popup konfirmasi hapus label.
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    String labelName,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFCF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Delete Label?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Are you sure you want to delete "$labelName"? '
                  'Tasks using this label will remain saved, '
                  'but will no longer have this label.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navy,
                            side: const BorderSide(color: Color(0xFFE5E0D5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            foregroundColor: _navy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  // Membuka halaman tambah label.
  Future<void> _openCreateLabelScreen(BuildContext context, int userId) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateLabelScreen(userId: userId)),
    );
  }

  // Mengedit label dan menyinkronkan nama label pada tugas.
  Future<void> _editLabel(
    BuildContext context,
    LabelModel label,
    int userId,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLabelSheet(label: label, userId: userId),
    );

    if (!context.mounted || result != true) return;

    final labelProvider = context.read<LabelProvider>();
    final taskProvider = context.read<TaskProvider>();

    final updatedLabels = labelProvider.getLabelsForUser(userId);

    LabelModel updatedLabel = label;

    for (final item in updatedLabels) {
      if (item.id == label.id) {
        updatedLabel = item;
        break;
      }
    }

    final relatedTasks = taskProvider.tasks.where((task) {
      return task.userId == userId && task.labelId == label.id;
    }).toList();

    for (final task in relatedTasks) {
      taskProvider.updateTask(
        id: task.id,
        labelId: updatedLabel.id,
        labelName: updatedLabel.namaLabel,
        judul: task.judul,
        deskripsi: task.deskripsi,
        deadline: task.deadline,
        isCompleted: task.isCompleted,
      );
    }

    if (!context.mounted) return;

    await _showStatusDialog(
      context,
      title: 'Label updated!',
      message: 'Your label has been updated successfully.',
    );
  }

  // Menghapus label tanpa menghapus tugas.
  Future<void> _deleteLabel(
    BuildContext context,
    LabelModel label,
    int userId,
  ) async {
    final confirmed = await _showDeleteConfirmation(context, label.namaLabel);

    if (!context.mounted || !confirmed) return;

    final labelProvider = context.read<LabelProvider>();
    final taskProvider = context.read<TaskProvider>();

    // Simpan tugas yang menggunakan label sebelum label dihapus.
    final relatedTasks = taskProvider.tasks.where((task) {
      return task.userId == userId && task.labelId == label.id;
    }).toList();

    final success = await labelProvider.deleteLabel(
      userId: userId,
      labelId: label.id,
    );

    if (!success) {
      if (!context.mounted) return;

      await _showStatusDialog(
        context,
        title: 'Unable to delete label',
        message: 'Something went wrong. Please try again.',
        isSuccess: false,
      );
      return;
    }

    // Lepaskan label dari tugas yang terkait.
    for (final task in relatedTasks) {
      taskProvider.updateTask(
        id: task.id,
        clearLabel: true,
        judul: task.judul,
        deskripsi: task.deskripsi,
        deadline: task.deadline,
        isCompleted: task.isCompleted,
      );
    }

    if (!context.mounted) return;

    await _showStatusDialog(
      context,
      title: 'Label deleted!',
      message: 'Your label has been successfully deleted.',
    );
  }

  // Tampilan ketika belum ada label.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEE4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.label_outline, size: 32, color: _navy),
          ),
          const SizedBox(height: 14),
          const Text(
            'No labels yet',
            style: TextStyle(
              color: _navy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create labels to organize your tasks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Kartu label.
  Widget _buildLabelCard(
    BuildContext context,
    LabelModel label,
    int userId,
    List<TaskModel> userTasks,
  ) {
    final taskCount = _getTaskCount(userTasks, label.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE7E2)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LabelDetailScreen(label: label, userId: userId),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: label.color,
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        title: Text(
          label.namaLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF342C29),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Tasks • $taskCount',
            style: const TextStyle(fontSize: 11, color: Color(0xFF99918B)),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF99918B)),
          onSelected: (value) {
            if (value == 'edit') {
              _editLabel(context, label, userId);
            } else if (value == 'delete') {
              _deleteLabel(context, label, userId);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Edit Label'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Delete Label', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in first.')));
    }

    final labelProvider = context.watch<LabelProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final userLabels = labelProvider.getLabelsForUser(user.id);

    final userTasks = taskProvider.tasks.where((task) {
      return task.userId == user.id;
    }).toList();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text(
          'Label',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF342C29),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Label',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF342C29),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create and organize your tasks.',
                style: TextStyle(fontSize: 14, color: Color(0xFF99918B)),
              ),
              const SizedBox(height: 24),

              // ADD LABEL BUTTON
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openCreateLabelScreen(context, user.id);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Add Label',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: _navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LABEL LIST
              Expanded(
                child: userLabels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: userLabels.length,
                        itemBuilder: (context, index) {
                          return _buildLabelCard(
                            context,
                            userLabels[index],
                            user.id,
                            userTasks,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// LABEL DETAIL SCREEN
// ======================================================

class LabelDetailScreen extends StatefulWidget {
  final LabelModel label;
  final int userId;

  const LabelDetailScreen({
    super.key,
    required this.label,
    required this.userId,
  });

  @override
  State<LabelDetailScreen> createState() => _LabelDetailScreenState();
}

class _LabelDetailScreenState extends State<LabelDetailScreen> {
  static const Color _background = Color(0xFFFAF7EC);
  static const Color _navy = Color(0xFF101C3C);
  static const Color _orange = Color(0xFFFFA800);
  static const Color _grey = Color(0xFF8C8C8C);

  int _selectedTab = 0;

  // Mengambil tugas berdasarkan label dan status.
  List<TaskModel> _getVisibleTasks(List<TaskModel> allTasks) {
    return allTasks.where((task) {
      return task.isCompleted == (_selectedTab == 1);
    }).toList()..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // Mengubah status tugas.
  void _toggleTask(TaskModel task) {
    context.read<TaskProvider>().toggleTaskStatus(task.id);
  }

  // Tab Pending dan Completed.
  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: _orange, width: 1) : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: _navy,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Selalu membaca data terbaru dari TaskProvider.
    final allTasks = context.watch<TaskProvider>().tasks.where((task) {
      return task.userId == widget.userId && task.labelId == widget.label.id;
    }).toList();

    final visibleTasks = _getVisibleTasks(allTasks);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: _navy, size: 21),
        ),
        title: Text(
          widget.label.namaLabel,
          style: const TextStyle(
            color: _navy,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label.namaLabel,
              style: const TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${allTasks.length} tasks',
              style: const TextStyle(color: _grey, fontSize: 9),
            ),

            const SizedBox(height: 14),

            // PENDING AND COMPLETED TABS
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [_buildTab('PENDING', 0), _buildTab('COMPLETED', 1)],
              ),
            ),

            const SizedBox(height: 12),

            // TASK LIST
            Expanded(
              child: visibleTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EFE3),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.label_outline,
                              size: 30,
                              color: Color(0xFF26364D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedTab == 0
                                ? 'No pending tasks'
                                : 'No completed tasks',
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedTab == 0
                                ? 'Tasks with this label will appear here.'
                                : 'Completed tasks with this label will appear here.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: visibleTasks.length,
                      itemBuilder: (context, index) {
                        final task = visibleTasks[index];

                        // Gunakan TaskCard yang sama dengan Home.
                        return TaskCard(
                          task: task,
                          labelName: widget.label.namaLabel,
                          labelColor: widget.label.color,
                          onChanged: () {
                            _toggleTask(task);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// EDIT LABEL BOTTOM SHEET
// ======================================================

class _EditLabelSheet extends StatefulWidget {
  final LabelModel label;
  final int userId;

  const _EditLabelSheet({required this.label, required this.userId});

  @override
  State<_EditLabelSheet> createState() => _EditLabelSheetState();
}

class _EditLabelSheetState extends State<_EditLabelSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  static const Color _navy = Color(0xFF101C3C);
  static const Color _orange = Color(0xFFFFA800);

  static const List<String> _colors = [
    '#80AFFF',
    '#FFDA55',
    '#FF941A',
    '#56E65D',
    '#E94C50',
    '#EF91B6',
    '#A985E8',
    '#D99A31',
    '#E6D5B7',
    '#666970',
  ];

  String? _selectedColor;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.label.namaLabel);

    _selectedColor = widget.label.kodeWarna;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Mengubah kode warna menjadi Color.
  Color _parseColor(String hex) {
    final value = hex.replaceFirst('#', '');
    final normalized = value.length == 6 ? 'FF$value' : value;

    return Color(int.parse(normalized, radix: 16));
  }

  // Menyimpan perubahan label.
  Future<void> _saveLabel() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    bool success = false;

    try {
      success = await context.read<LabelProvider>().updateLabel(
        userId: widget.userId,
        labelId: widget.label.id,
        labelName: _nameController.text.trim(),
        colorCode: _selectedColor,
        clearColor: _selectedColor == null,
      );
    } catch (error) {
      success = false;
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isSaving = false;
        _errorMessage =
            'Label name is already used or failed to update. Please try again.';
      });
    }
  }

  // Pilihan warna.
  Widget _buildColorOption(String color) {
    final isSelected = _selectedColor == color;

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _selectedColor = isSelected ? null : color;
              });
            },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _parseColor(color),
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: _navy, width: 3)
              : Border.all(color: Colors.black12),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 19)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFEFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HANDLE
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D2CD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Label',
                      style: TextStyle(
                        color: _navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: _navy),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  'Label name',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Label name',
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8E2D8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8E2D8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _orange),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    errorText: _errorMessage,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Label name is required.';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Label color',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colors.map(_buildColorOption).toList(),
                ),

                const SizedBox(height: 24),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveLabel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: _navy,
                      disabledBackgroundColor: _orange.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
