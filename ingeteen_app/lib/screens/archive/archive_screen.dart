import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_logo.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  static const Color cream = Color(0xFFF9F5E9);
  static const Color navy = Color(0xFF26364D);
  static const Color orange = Color(0xFFFFB31A);
  static const Color muted = Color(0xFF8490A0);
  static const Color cardBorder = Color(0xFFE8E5DC);
  static const Color red = Color(0xFFE45B64);
  static const Color softRed = Color(0xFFFFEEEE);
  static const Color selectedBlue = Color(0xFFF0F5FF);

  bool _showCompleted = false;
  bool _isSelectionMode = false;
  bool _isProcessing = false;

  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<TaskProvider>().loadArchive(user.id);
      }
    });
  }

  List<ArchivedTask> _getVisibleTasks(List<ArchivedTask> items) {
    return items.where((item) {
      return item.task.isCompleted == _showCompleted;
    }).toList()
      ..sort(
        (a, b) => b.archivedAt.compareTo(a.archivedAt),
      );
  }

  void _changeTab(bool completed) {
    setState(() {
      _showCompleted = completed;
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _startSelection() {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.clear();
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(int taskId) {
    setState(() {
      if (_selectedIds.contains(taskId)) {
        _selectedIds.remove(taskId);
      } else {
        _selectedIds.add(taskId);
      }

      if (_selectedIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<ArchivedTask> tasks) {
    setState(() {
      if (tasks.isEmpty) return;

      final allSelected = tasks.every(
        (item) => _selectedIds.contains(item.task.id),
      );

      if (allSelected) {
        _selectedIds.removeAll(
          tasks.map((item) => item.task.id),
        );
      } else {
        _selectedIds.addAll(
          tasks.map((item) => item.task.id),
        );
      }

      _isSelectionMode = _selectedIds.isNotEmpty;
    });
  }

  Future<bool> _showConfirmationDialog({
    required String heading,
    required String title,
    required String description,
    required String cancelText,
    required String confirmText,
    required Color confirmColor,
    required Color headingColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading.toUpperCase(),
                  style: TextStyle(
                    color: headingColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 43,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F1EF),
                            foregroundColor: navy,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: SizedBox(
                        height: 43,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            style: const TextStyle(
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

    return result == true;
  }

  Future<bool> _confirmMoveToTrash(int count) {
    return _showConfirmationDialog(
      heading: 'Move to Trash',
      title: count == 1
          ? 'Delete item?'
          : 'Delete $count items?',
      description: count == 1
          ? 'This item will be moved to Trash. You can restore it later from the Trash page.'
          : 'These $count items will be moved to Trash. You can restore them later from the Trash page.',
      cancelText: 'Cancel',
      confirmText: count == 1 ? 'Delete Item' : 'Delete Items',
      confirmColor: red,
      headingColor: red,
    );
  }

  Future<bool> _confirmUnarchive(int count) {
    return _showConfirmationDialog(
      heading: 'Move out of Archive',
      title: count == 1
          ? 'Unarchive 1 item?'
          : 'Unarchive $count items?',
      description: count == 1
          ? 'This item will return to its original list. You can archive it again anytime.'
          : 'These $count items will return to their original list. You can archive them again anytime.',
      cancelText: 'Cancel',
      confirmText: 'Unarchive',
      confirmColor: navy,
      headingColor: navy,
    );
  }

  Future<void> _moveTasksToTrash(
    List<int> taskIds,
    int userId,
  ) async {
    if (taskIds.isEmpty || _isProcessing) return;

    final confirmed = await _confirmMoveToTrash(taskIds.length);

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = context.read<TaskProvider>();

      for (final id in taskIds) {
        await provider.deleteArchivedTask(
          id,
          userId: userId,
        );
      }

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskIds.length == 1
                ? 'Task moved to Trash.'
                : '${taskIds.length} tasks moved to Trash.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to move tasks to Trash: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _unarchiveTasks(
    List<int> taskIds,
    int userId,
  ) async {
    if (taskIds.isEmpty || _isProcessing) return;

    final confirmed = await _confirmUnarchive(taskIds.length);

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = context.read<TaskProvider>();

      for (final id in taskIds) {
        await provider.unarchiveTask(
          id,
          userId: userId,
        );
      }

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskIds.length == 1
                ? 'Task restored to Home.'
                : '${taskIds.length} tasks restored to Home.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore tasks: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _openDrawerPage(String route) {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final taskProvider = context.watch<TaskProvider>();

    final allItems = user == null
        ? <ArchivedTask>[]
        : taskProvider.archiveItemsForUser(user.id);

    final visibleTasks = _getVisibleTasks(allItems);
    final selectedCount = _selectedIds.length;

    final allVisibleSelected = visibleTasks.isNotEmpty &&
        visibleTasks.every(
          (item) => _selectedIds.contains(item.task.id),
        );

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, size: 21),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          _isSelectionMode ? '$selectedCount selected' : 'Archive',
          style: const TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSelectionMode)
            TextButton(
              onPressed: _cancelSelection,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (visibleTasks.isNotEmpty)
            TextButton(
              onPressed: _startSelection,
              child: const Text(
                'Select',
                style: TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTabs(),
            if (_isSelectionMode && visibleTasks.isNotEmpty)
              _buildSelectionHeader(
                allVisibleSelected,
                visibleTasks,
              ),
            Expanded(
              child: user == null || visibleTasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(
                      visibleTasks,
                      user.id,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isSelectionMode && selectedCount > 0
          ? _buildSelectionBottomBar(user?.id)
          : null,
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabButton(
            title: 'PENDING',
            selected: !_showCompleted,
            onTap: () => _changeTab(false),
          ),
          _buildTabButton(
            title: 'COMPLETED',
            selected: _showCompleted,
            onTap: () => _changeTab(true),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: orange, width: 0.9)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: selected ? orange : muted,
              fontSize: 10,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionHeader(
    bool allSelected,
    List<ArchivedTask> visibleTasks,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Choose items to manage',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: _isProcessing
                ? null
                : () => _selectAll(visibleTasks),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF0EDE4),
              foregroundColor: navy,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              allSelected ? 'Deselect all' : 'Select all',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<ArchivedTask> tasks, int userId) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index], userId);
      },
    );
  }

  Widget _buildTaskCard(ArchivedTask item, int userId) {
    final task = item.task;
    final isSelected = _selectedIds.contains(task.id);

    final label = (task.labelName ?? '').trim().isEmpty
        ? 'No Label'
        : task.labelName!.trim();

    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');

    return GestureDetector(
      onTap: _isSelectionMode
          ? () => _toggleSelection(task.id)
          : null,
      onLongPress: !_isSelectionMode
          ? () {
              _startSelection();
              _toggleSelection(task.id);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBlue : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? navy : cardBorder,
            width: isSelected ? 1.1 : 0.8,
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
                    style: const TextStyle(
                      color: navy,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isSelectionMode)
                  _buildSelectionCheckbox(isSelected)
                else
                  _buildLabelChip(label),
              ],
            ),
            if (task.deskripsi.trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                task.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (_isSelectionMode)
              _buildLabelChip(label)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 8),
            _buildDateRow(
              Icons.calendar_today_outlined,
              'Created ${dateFormat.format(task.createdAt)}',
            ),
            const SizedBox(height: 5),
            _buildDateRow(
              Icons.event_outlined,
              'Deadline ${dateFormat.format(task.deadline)}',
            ),
            if (!_isSelectionMode) ...[
              const SizedBox(height: 9),
              Row(
                children: [
                  _buildCardAction(
                    'Restore',
                    orange,
                    () => _unarchiveTasks([task.id], userId),
                  ),
                  const SizedBox(width: 9),
                  _buildCardAction(
                    'Delete',
                    red,
                    () => _moveTasksToTrash([task.id], userId),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCheckbox(bool selected) {
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: selected ? navy : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? navy : muted,
          width: 1,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildLabelChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: navy,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 11,
          color: muted,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardAction(
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEC),
                borderRadius: BorderRadius.circular(19),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: navy,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.archive_outlined,
                  color: navy,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 13),
            const Text(
              'Your archive is empty',
              style: TextStyle(
                color: navy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Archived notes and tasks will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar(int? userId) {
    final selectedIds = _selectedIds.toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: cream,
        border: Border(
          top: BorderSide(color: cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_selectedIds.length} item${_selectedIds.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                color: muted,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isProcessing || userId == null
                          ? null
                          : () => _unarchiveTasks(
                                selectedIds,
                                userId,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            navy.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Unarchive (${_selectedIds.length})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isProcessing || userId == null
                          ? null
                          : () => _moveTasksToTrash(
                                selectedIds,
                                userId,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: softRed,
                        foregroundColor: red,
                        disabledBackgroundColor:
                            softRed.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: Text(
                        'Delete (${_selectedIds.length})',
                        style: const TextStyle(
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
  }

  // NAVIGATION DRAWER
  Widget _buildDrawer() {
    const selectedBackground = Color(0xFFFFE8B0);

    final username =
        context.read<AuthProvider>().user?.username ?? 'User';

    Widget menuItem(
      IconData icon,
      String title, {
      bool selected = false,
      VoidCallback? onTap,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected ? selectedBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Icon(
            icon,
            color: navy,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
        ),
      );
    }

    return Drawer(
      backgroundColor: cream,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  menuItem(
                    Icons.description_outlined,
                    'All Tasks',
                    onTap: () {
                      _openDrawerPage(AppRoutes.home);
                    },
                  ),
                  menuItem(
                    Icons.tune,
                    'Urgent',
                    onTap: () {
                      _openDrawerPage(AppRoutes.home);
                    },
                  ),
                  menuItem(
                    Icons.label_outline,
                    'Labels',
                    onTap: () {
                      _openDrawerPage(AppRoutes.label);
                    },
                  ),
                  menuItem(
                    Icons.archive_outlined,
                    'Archive',
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  menuItem(
                    Icons.delete_outline,
                    'Trash',
                    onTap: () {
                      _openDrawerPage(AppRoutes.trash);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7FB3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'US',
                          style: TextStyle(
                            color: navy,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Profile Settings',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Log out',
                      onPressed: () {
                        context.read<AuthProvider>().logout();

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (_) => false,
                        );
                      },
                      icon: const Icon(
                        Icons.logout,
                        color: navy,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}