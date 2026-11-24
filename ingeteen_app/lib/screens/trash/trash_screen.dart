import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_logo.dart';
import '../archive/archive_screen.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  static const Color navy = Color(0xFF26364D);
  static const Color cream = Color(0xFFF9F5E9);
  static const Color orange = Color(0xFFFFB31A);
  static const Color mutedText = Color(0xFF8490A0);
  static const Color red = Color(0xFFB8202D);
  static const Color green = Color(0xFF55A66B);
  static const Color cardBorder = Color(0xFFE8E5DC);
  static const Color avatarBlue = Color(0xFF7FB3FF);

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<TaskProvider>().loadTrash(user.id);
      }
    });
  }

  // =========================
  // RESTORE TASK
  // =========================

  Future<void> _restoreTask(int taskId, int userId) async {
    if (_isProcessing) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Restore this task?',
      message: 'This task will be moved back to your task list.',
      confirmText: 'Restore',
      confirmColor: green,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await context.read<TaskProvider>().restoreTask(
            taskId,
            userId: userId,
          );

      if (!mounted) return;

      await _showSuccessDialog(
        title: 'Task restored successfully!',
        message: 'This task has been moved back to your task list.',
        iconColor: green,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to restore task: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // =========================
  // DELETE FOREVER
  // =========================

  Future<void> _deleteForever(int taskId, int userId) async {
    if (_isProcessing) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Delete permanently?',
      message:
          'This task will be permanently deleted from this device and cannot be restored.',
      confirmText: 'Delete Forever',
      confirmColor: red,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await context.read<TaskProvider>().deleteForever(
            taskId,
            userId: userId,
          );

      if (!mounted) return;

      await _showSuccessDialog(
        title: 'Task deleted successfully!',
        message: 'This task has been permanently removed from this device.',
        iconColor: green,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Failed to delete task: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // =========================
  // CONFIRMATION DIALOG
  // =========================

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: mutedText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: navy),
              ),
            ),
            ElevatedButton(
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
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // =========================
  // SUCCESS DIALOG
  // =========================

  Future<void> _showSuccessDialog({
    required String title,
    required String message,
    required Color iconColor,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: iconColor,
                size: 52,
              ),
              const SizedBox(height: 14),
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
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // NAVIGATION
  // =========================

  void _openHome() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _openLabels() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, AppRoutes.label);
  }

  void _openArchive() {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ArchiveScreen(),
      ),
    );
  }

  void _logout() {
    context.read<AuthProvider>().logout();

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final taskProvider = context.watch<TaskProvider>();

    final trashItems = user == null
        ? <TrashedTask>[]
        : taskProvider.trashItemsForUser(user.id);

    final username = user?.username ?? 'User';

    return Scaffold(
      backgroundColor: cream,
      drawer: _buildDrawer(username),
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 8,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                size: 21,
                color: navy,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Trash',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deleted tasks are stored here until you restore or permanently delete them.',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: user == null
                    ? _buildEmptyState()
                    : trashItems.isEmpty
                        ? _buildEmptyState()
                        : _buildTaskList(
                            trashItems,
                            user.id,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // TASK LIST
  // =========================

  Widget _buildTaskList(
    List<TrashedTask> items,
    int userId,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ...items.map(
          (item) => _buildTrashCard(item, userId),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFBEBDD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: red,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Permanently deleted items cannot be restored.',
                  style: TextStyle(
                    color: red,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================
  // TRASH CARD
  // =========================

  Widget _buildTrashCard(
    TrashedTask item,
    int userId,
  ) {
    final task = item.task;
    final deletedAt = item.deletedAt;

    final label = (task.labelName ?? '').trim().isEmpty
        ? 'No Label'
        : task.labelName!.trim();

    final dateFormat = DateFormat('dd MMM yyyy · HH:mm');

    final deletedText = DateTime.now().difference(deletedAt).inDays == 0
        ? 'Deleted today'
        : 'Deleted ${DateTime.now().difference(deletedAt).inDays} days ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: cardBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.035),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
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
              ),
              const Spacer(),
              Text(
                deletedText,
                style: const TextStyle(
                  color: red,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            task.judul,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (task.deskripsi.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              task.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: mutedText,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 11,
                color: mutedText,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Deleted ${dateFormat.format(deletedAt)}',
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _restoreTask(task.id, userId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: const BorderSide(color: green),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Restore',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _deleteForever(task.id, userId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: red,
                    side: const BorderSide(color: red),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Delete Forever',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEC),
                borderRadius: BorderRadius.circular(18),
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
                  Icons.delete_outline,
                  color: navy,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Trash is empty',
              style: TextStyle(
                color: navy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Deleted tasks will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // NAVIGATION DRAWER
  // =========================

  Widget _buildDrawer(String username) {
    return Drawer(
      backgroundColor: cream,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 25, 20, 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(fontSize: 17),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _drawerItem(
                    icon: Icons.description_outlined,
                    title: 'All Tasks',
                    onTap: _openHome,
                  ),
                  _drawerItem(
                    icon: Icons.checklist,
                    title: 'Urgent',
                    onTap: _openHome,
                  ),
                  _drawerItem(
                    icon: Icons.label_outline,
                    title: 'Labels',
                    onTap: _openLabels,
                  ),
                  _drawerItem(
                    icon: Icons.archive_outlined,
                    title: 'Archive',
                    onTap: _openArchive,
                  ),
                  _drawerItem(
                    icon: Icons.delete_outline,
                    title: 'Trash',
                    selected: true,
                    onTap: () {
                      Navigator.pop(context);
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
                    const CircleAvatar(
                      radius: 19,
                      backgroundColor: avatarBlue,
                      child: Text(
                        'US',
                        style: TextStyle(
                          color: navy,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              color: orange,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Log out',
                      onPressed: _logout,
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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFFFE8B0)
            : Colors.transparent,
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
            fontSize: 13,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}