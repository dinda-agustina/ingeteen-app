import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/label_provider.dart';
import '../../services/dummy_data.dart';
import '../../models/label_model.dart';
import '../../models/task_model.dart';
import 'label_create_screen.dart';

class LabelScreen extends StatefulWidget {
  const LabelScreen({super.key});

  @override
  State<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  int _getTaskCount(int userId, int labelId) {
    return DummyData.tasks.where((task) {
      return task.userId == userId && task.labelId == labelId;
    }).length;
  }

  Future<void> _openCreateLabelScreen(int userId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateLabelScreen(userId: userId),
      ),
    );

    if (!mounted || result != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Label added successfully.'),
      ),
    );
  }

  Future<void> _showEditLabelDialog(
    LabelModel label,
    int userId,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditLabelSheet(
        label: label,
        userId: userId,
      ),
    );

    if (!mounted || result != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Label updated successfully.'),
      ),
    );
  }

  Future<void> _showDeleteLabelDialog(
    LabelModel label,
    int userId,
  ) async {
    final taskCount = _getTaskCount(userId, label.id);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Label'),
          content: Text(
            taskCount > 0
                ? 'Are you sure you want to delete the label '
                    '"${label.namaLabel}"?\n\n'
                    '$taskCount tasks using this label will remain saved, '
                    'but will no longer be associated with it.'
                : 'Are you sure you want to delete the label '
                    '"${label.namaLabel}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    final success = context.read<LabelProvider>().deleteLabel(
          userId: userId,
          labelId: label.id,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Label deleted successfully.'
              : 'Failed to delete label.',
        ),
      ),
    );
  }

  void _openLabelDetail(LabelModel label, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabelDetailScreen(
          label: label,
          userId: userId,
        ),
      ),
    );
  }

  Widget _buildAddLabelButton(int userId) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () => _openCreateLabelScreen(userId),
        icon: const Icon(Icons.add, size: 18),
        label: const Text(
          'Add Label',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA800),
          foregroundColor: const Color(0xFF101C3C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EEE4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.label_outline,
              size: 30,
              color: Color(0xFF101C3C),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No labels yet',
            style: TextStyle(
              color: Color(0xFF101C3C),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create labels to organize notes and tasks.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelCard(LabelModel label, int userId) {
    final taskCount = _getTaskCount(userId, label.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEAE7E2),
        ),
      ),
      child: ListTile(
        onTap: () => _openLabelDetail(label, userId),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF99918B),
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: Color(0xFF99918B),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditLabelDialog(label, userId);
            } else if (value == 'delete') {
              _showDeleteLabelDialog(label, userId);
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
                  Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Delete Label',
                    style: TextStyle(color: Colors.red),
                  ),
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
    final labelProvider = context.watch<LabelProvider>();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in first.'),
        ),
      );
    }

    final userLabels = labelProvider.getLabelsForUser(user.id);
    final hasLabels = userLabels.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F1),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF99918B),
                ),
              ),
              if (hasLabels) ...[
                const SizedBox(height: 24),
                _buildAddLabelButton(user.id),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: userLabels.length,
                    itemBuilder: (context, index) {
                      return _buildLabelCard(
                        userLabels[index],
                        user.id,
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _buildEmptyState(),
                ),
                const SizedBox(height: 12),
                _buildAddLabelButton(user.id),
              ],
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

  late List<TaskModel> _tasks;

  @override
  void initState() {
    super.initState();

    _tasks = DummyData.tasks
        .where(
          (task) =>
              task.userId == widget.userId &&
              task.labelId == widget.label.id,
        )
        .toList();
  }

  List<TaskModel> get _pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> get _completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  List<TaskModel> get _visibleTasks {
    return _selectedTab == 0 ? _pendingTasks : _completedTasks;
  }

  void _toggleTask(TaskModel task, bool? value) {
    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);

      if (index == -1) return;

      _tasks[index] = task.copyWith(
        isCompleted: value ?? false,
      );
    });
  }

  Color _deadlineColor(TaskModel task) {
    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return const Color(0xFFFFA800);
      case DeadlineLevel.near:
        return const Color(0xFF4EDB55);
      case DeadlineLevel.safe:
        return const Color(0xFF80AFFF);
    }
  }

  String _deadlineText(TaskModel task) {
    switch (task.deadlineLevel) {
      case DeadlineLevel.urgent:
        return 'Due soon';
      case DeadlineLevel.near:
        return 'On track';
      case DeadlineLevel.safe:
        return 'On track';
    }
  }

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
            border: isSelected
                ? Border.all(color: _orange, width: 1)
                : null,
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

  Widget _buildTaskCard(TaskModel task) {
    final completed = task.isCompleted;
    final borderColor = completed
        ? const Color(0xFFE5E1D7)
        : _deadlineColor(task);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
          width: completed ? 1 : 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.judul,
                  style: TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                    decorationColor: _navy,
                  ),
                ),
              ),
              SizedBox(
                width: 25,
                height: 25,
                child: Checkbox(
                  value: completed,
                  onChanged: (value) => _toggleTask(task, value),
                  activeColor: const Color(0xFF52677F),
                  checkColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF52677F),
                    width: 1.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (task.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.deskripsi,
              style: TextStyle(
                color: completed ? _grey : const Color(0xFF777777),
                fontSize: 9,
                decoration:
                    completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Text(
            completed ? 'Completed' : _deadlineText(task),
            style: TextStyle(
              color: completed
                  ? const Color(0xFF52677F)
                  : task.deadlineLevel == DeadlineLevel.urgent
                      ? const Color(0xFF9A6500)
                      : const Color(0xFF238A37),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: widget.label.color.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.label.namaLabel,
              style: const TextStyle(
                color: _navy,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 10,
                color: _grey,
              ),
              const SizedBox(width: 5),
              Text(
                DateFormat('d MMM yyyy • HH:mm', 'en_US')
                    .format(task.deadline),
                style: const TextStyle(
                  color: _grey,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visibleTasks;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: _navy,
            size: 21,
          ),
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
              '${_tasks.length} tasks',
              style: const TextStyle(
                color: _grey,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEE4),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  _buildTab('PENDING', 0),
                  _buildTab('COMPLETED', 1),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        _selectedTab == 0
                            ? 'No pending tasks.'
                            : 'No completed tasks.',
                        style: const TextStyle(
                          color: _grey,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(tasks[index]);
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

  const _EditLabelSheet({
    required this.label,
    required this.userId,
  });

  @override
  State<_EditLabelSheet> createState() => _EditLabelSheetState();
}

class _EditLabelSheetState extends State<_EditLabelSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  static const Color _navy = Color(0xFF101C3C);
  static const Color _orange = Color(0xFFFFA800);
  static const Color _cream = Color(0xFFFFFEFC);

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.label.namaLabel,
    );

    _selectedColor = _colors.contains(widget.label.kodeWarna)
        ? widget.label.kodeWarna
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final value = hex.replaceFirst('#', '');

    return Color(
      int.parse(
        value.length == 6 ? 'FF$value' : value,
        radix: 16,
      ),
    );
  }

  Future<void> _saveLabel() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingLabelDialog(),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    bool success = false;

    try {
      success = context.read<LabelProvider>().updateLabel(
            userId: widget.userId,
            labelId: widget.label.id,
            labelName: _nameController.text.trim(),
            colorCode: _selectedColor,
            clearColor: _selectedColor == null,
          );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update label. Make sure the label name is not already in use.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildColorOption(String color) {
    final isSelected = _selectedColor == color;

    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: GestureDetector(
          onTap: _isSaving
              ? null
              : () {
                  setState(() {
                    _selectedColor = isSelected ? null : color;
                  });
                },
          child: Container(
            width: isSelected ? 38 : 28,
            height: isSelected ? 38 : 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: _orange, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _parseColor(color),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 1.5)
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 19,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: screenHeight * 0.65,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: const BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
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
                      icon: const Icon(
                        Icons.close,
                        color: _navy,
                        size: 21,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Label name',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 12,
                  ),
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
                    suffixIcon: IconButton(
                      onPressed:
                          _isSaving ? null : _nameController.clear,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: Color(0xFF777777),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8E2D8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8E2D8),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _orange),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Label name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Label color',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colors.map(_buildColorOption).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveLabel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: _navy,
                      disabledBackgroundColor:
                          _orange.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text(
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

// ======================================================
// SAVING LABEL DIALOG
// ======================================================

class _SavingLabelDialog extends StatelessWidget {
  const _SavingLabelDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFEFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(11),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1DF),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFFF941A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Saving label...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101C3C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please wait while we save your label.\n'
              'This will only take a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}