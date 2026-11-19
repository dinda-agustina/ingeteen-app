import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../models/label_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/label_provider.dart';
import '../services/dummy_data.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const navy = Color(0xFF26364D);
  static const cream = Color(0xFFF9F5E9);
  static const orange = Color(0xFFFFB31A);
  static const mutedText = Color(0xFF999999);
  static const borderColor = Color(0xFFE5E0D5);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulController;
  late final TextEditingController _deskripsiController;

  DateTime? _deadline;
  int? _selectedLabelId;

  bool _labelInitialized = false;
  bool _isSaving = false;
  bool _allowPop = false;
  bool _isHandlingBack = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    _judulController = TextEditingController(
      text: widget.task?.judul ?? '',
    );

    _deskripsiController = TextEditingController(
      text: widget.task?.deskripsi ?? '',
    );

    _deadline = widget.task?.deadline;
    _selectedLabelId = widget.task?.labelId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_labelInitialized) return;

    final userId =
        context.read<AuthProvider>().user?.id ??
            DummyData.user.id;

    final labels =
        context.read<LabelProvider>().getLabelsForUser(userId);

    if (_selectedLabelId == null &&
        widget.task?.labelName != null) {
      for (final label in labels) {
        if (label.namaLabel.toLowerCase() ==
            widget.task!.labelName!.toLowerCase()) {
          _selectedLabelId = label.id;
          break;
        }
      }
    }

    _labelInitialized = true;
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // Select deadline date.
  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select deadline date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: orange,
              onPrimary: navy,
              surface: Colors.white,
              onSurface: navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      final currentTime = _deadline ??
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            23,
            59,
          );

      _deadline = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        currentTime.hour,
        currentTime.minute,
      );
    });
  }

  // Select deadline time.
  Future<void> _selectTime() async {
    final now = DateTime.now();

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _deadline != null
          ? TimeOfDay.fromDateTime(_deadline!)
          : const TimeOfDay(hour: 23, minute: 59),
      helpText: 'Select deadline time',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: orange,
              onPrimary: navy,
              surface: Colors.white,
              onSurface: navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      final currentDate = _deadline ?? now;

      _deadline = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  // Discard changes dialog.
  Future<bool> _showDiscardDialog() async {
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
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.undo_rounded,
                    color: navy,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Discard changes?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'You have unsaved changes. Leaving now will discard your edits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedText,
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
                      Navigator.pop(dialogContext, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Keep Editing',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: const BorderSide(
                        color: borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Discard Changes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

    return result ?? false;
  }

  // Handle back navigation.
  Future<void> _handleBack() async {
    if (_isHandlingBack || _allowPop || _isSaving || !mounted) {
      return;
    }

    _isHandlingBack = true;

    try {
      final shouldLeave = await _showDiscardDialog();

      if (!mounted || !shouldLeave) return;

      setState(() {
        _allowPop = true;
      });

      await WidgetsBinding.instance.endOfFrame;

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      _isHandlingBack = false;
    }
  }

  // Saving task dialog.
  Future<void> _showSavingDialog() async {
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: const Color(0xFFFFFCF5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: orange,
                      backgroundColor: const Color(0xFFFFE8B5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saving task...',
                    style: TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please wait while we save your task.\nThis will only take a moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Save error dialog.
  Future<bool> _showSaveErrorDialog() async {
    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE9E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Couldn’t save task',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Your task wasn’t saved. Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: const BorderSide(
                        color: borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

    return result ?? false;
  }

  // Success dialog.
  Future<void> _showSuccessDialog() async {
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4C9B63),
                    size: 23,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isEditing ? 'Task saved!' : 'Task added!',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Your task has been saved successfully. You are all set!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedText,
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
                      backgroundColor: orange,
                      foregroundColor: navy,
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

  // General message dialog.
  Future<void> _showMessageDialog({
    required String title,
    required String message,
    required IconData icon,
  }) async {
    await showDialog<void>(
      context: context,
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
                Icon(
                  icon,
                  color: orange,
                  size: 35,
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'OK',
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

  // Perform task save.
  void _performTaskSave() {
    final userId =
        context.read<AuthProvider>().user?.id ??
            DummyData.user.id;

    final labelProvider = context.read<LabelProvider>();

    LabelModel? selectedLabel;

    for (final label in labelProvider.getLabelsForUser(userId)) {
      if (label.id == _selectedLabelId) {
        selectedLabel = label;
        break;
      }
    }

    final taskProvider = context.read<TaskProvider>();

    if (_isEditing) {
      taskProvider.updateTask(
        id: widget.task!.id,
        labelId: selectedLabel?.id,
        labelName: selectedLabel?.namaLabel,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        deadline: _deadline!,
        isCompleted: widget.task!.isCompleted,
      );
    } else {
      taskProvider.addTask(
        userId: userId,
        labelId: selectedLabel?.id,
        labelName: selectedLabel?.namaLabel,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        deadline: _deadline!,
        isCompleted: false,
      );
    }
  }

  // Save task.
  Future<void> _saveTask() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_deadline == null) {
      await _showMessageDialog(
        title: 'Deadline required',
        message: 'Please select a deadline for your task.',
        icon: Icons.calendar_today_outlined,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      while (mounted) {
        // Open saving dialog.
        final savingDialogFuture = _showSavingDialog();

        await WidgetsBinding.instance.endOfFrame;

        // Allow the dialog to be visible.
        await Future.delayed(
          const Duration(milliseconds: 800),
        );

        if (!mounted) return;

        try {
          // Save or update task.
          _performTaskSave();

          if (!mounted) return;

          // Close saving dialog.
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop();

          await savingDialogFuture;

          if (!mounted) return;

          setState(() {
            _isSaving = false;
          });

          // Show success dialog.
          await _showSuccessDialog();

          if (!mounted) return;

          setState(() {
            _allowPop = true;
          });

          await WidgetsBinding.instance.endOfFrame;

          if (mounted) {
            Navigator.of(context).pop();
          }

          return;
        } catch (error) {
          if (!mounted) return;

          // Close saving dialog.
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop();

          await savingDialogFuture;

          if (!mounted) return;

          // Show error dialog.
          final retry = await _showSaveErrorDialog();

          if (!mounted || !retry) {
            setState(() {
              _isSaving = false;
            });
            return;
          }

          // Try Again: repeat the saving process.
        }
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      await _showMessageDialog(
        title: 'Something went wrong',
        message: 'Please try again.',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        context.watch<AuthProvider>().user?.id ??
            DummyData.user.id;

    final labels = context
        .watch<LabelProvider>()
        .getLabelsForUser(userId);

    final selectedLabelId = labels.any(
      (label) => label.id == _selectedLabelId,
    )
        ? _selectedLabelId
        : null;

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _allowPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: cream,
        appBar: AppBar(
          backgroundColor: cream,
          foregroundColor: navy,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 52,
          leading: IconButton(
            onPressed: _isSaving ? null : _handleBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: navy,
              size: 17,
            ),
          ),
          title: Text(
            _isEditing ? 'Edit Task' : 'Add Task',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 5, 18, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldTitle('Task Title'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _judulController,
                    textCapitalization:
                        TextCapitalization.sentences,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                    ),
                    decoration: _inputDecoration(
                      'Enter task title',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Task title is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildFieldTitle('Description'),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _deskripsiController,
                    minLines: 3,
                    maxLines: 3,
                    textCapitalization:
                        TextCapitalization.sentences,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    decoration: _inputDecoration(
                      'Enter task description',
                    ).copyWith(
                      contentPadding: const EdgeInsets.all(12),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _buildFieldTitle('Course / Label'),
                  const SizedBox(height: 7),
                  DropdownButtonFormField<int>(
                    initialValue: selectedLabelId,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: mutedText,
                      size: 20,
                    ),
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                    ),
                    decoration: _inputDecoration(
                      'Select a label',
                    ).copyWith(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    hint: const Text(
                      'Select a label',
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedText,
                      ),
                    ),
                    items: labels.map((label) {
                      return DropdownMenuItem<int>(
                        value: label.id,
                        child: Text(
                          label.namaLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _isSaving || labels.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _selectedLabelId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 15),

                  _buildFieldTitle('Deadline'),
                  const SizedBox(height: 7),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDateTimeField(
                          title: 'Date',
                          value: _deadline == null
                              ? 'Select date'
                              : DateFormat(
                                  'd MMMM yyyy',
                                  'en_US',
                                ).format(_deadline!),
                          icon: Icons.calendar_today_outlined,
                          onTap: _isSaving ? () {} : _selectDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _buildDateTimeField(
                          title: 'Time',
                          value: _deadline == null
                              ? '23:59'
                              : DateFormat('HH:mm')
                                  .format(_deadline!),
                          icon: Icons.access_time,
                          onTap: _isSaving ? () {} : _selectTime,
                        ),
                      ),
                    ],
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Created: ${DateFormat('d MMMM yyyy • HH:mm', 'en_US').format(widget.task!.createdAt)}',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                    Text(
                      'Last edited: ${DateFormat('d MMMM yyyy • HH:mm', 'en_US').format(widget.task!.updatedAt)}',
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 17),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: navy,
                        disabledBackgroundColor:
                            orange.withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: navy,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Save Changes'
                                  : 'Add Task',
                              style: const TextStyle(
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
      ),
    );
  }

  // Field title.
  Widget _buildFieldTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: navy,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
  }

  // Date and time input.
  Widget _buildDateTimeField({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  color: mutedText,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Input decoration.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: mutedText,
        fontSize: 11,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: orange,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.2,
        ),
      ),
    );
  }
}