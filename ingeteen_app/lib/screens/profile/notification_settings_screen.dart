import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const navy = Color(0xFF26364D);
  static const cream = Color(0xFFF9F5E9);
  static const mutedText = Color(0xFF999999);
  static const dividerColor = Color(0xFFF0EEE8);

  bool _notificationsEnabled = true;
  bool _taskRemindersEnabled = true;
  bool _threeDaysEnabled = true;
  bool _oneDayEnabled = true;
  bool _dueDayEnabled = true;
  bool _soundEnabled = false;

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;

      if (!value) {
        _taskRemindersEnabled = false;
        _threeDaysEnabled = false;
        _oneDayEnabled = false;
        _dueDayEnabled = false;
        _soundEnabled = false;
      }
    });
  }

  void _toggleTaskReminders(bool value) {
    setState(() {
      _taskRemindersEnabled = value;

      if (!value) {
        _threeDaysEnabled = false;
        _oneDayEnabled = false;
        _dueDayEnabled = false;
      }
    });
  }

  Widget _buildSettingTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 9,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.78,
              child: Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: Colors.white,
                activeTrackColor: navy,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD5D5D5),
                trackOutlineColor:
                    WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: dividerColor,
      height: 1,
      thickness: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: navy,
            size: 21,
          ),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Manage reminders and task deadlines.',
                style: TextStyle(
                  color: mutedText,
                  fontSize: 9,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              // All notification settings in one card.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    // Main notifications.
                    _buildSettingTile(
                      title: 'Notifications',
                      description:
                          'Enable all IngeTeen notifications.',
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                    ),

                    _buildDivider(),

                    // Task reminders.
                    _buildSettingTile(
                      title: 'Task reminders',
                      description:
                          'Local reminders for task deadlines.',
                      value: _taskRemindersEnabled,
                      enabled: _notificationsEnabled,
                      onChanged: _toggleTaskReminders,
                    ),

                    _buildDivider(),

                    // D-3 notification.
                    _buildSettingTile(
                      title: 'D-3 notification',
                      description:
                          'One day before the deadline.',
                      value: _threeDaysEnabled,
                      enabled: _notificationsEnabled &&
                          _taskRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _threeDaysEnabled = value;
                        });
                      },
                    ),

                    _buildDivider(),

                    // D-1 notification.
                    _buildSettingTile(
                      title: 'D-1 notification',
                      description:
                          'One day before the deadline.',
                      value: _oneDayEnabled,
                      enabled: _notificationsEnabled &&
                          _taskRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _oneDayEnabled = value;
                        });
                      },
                    ),

                    _buildDivider(),

                    // Due-day notification.
                    _buildSettingTile(
                      title: 'Due-day notification',
                      description: 'On the due date.',
                      value: _dueDayEnabled,
                      enabled: _notificationsEnabled &&
                          _taskRemindersEnabled,
                      onChanged: (value) {
                        setState(() {
                          _dueDayEnabled = value;
                        });
                      },
                    ),

                    _buildDivider(),

                    // Sound.
                    _buildSettingTile(
                      title: 'Sound',
                      description: 'Play notification sounds.',
                      value: _soundEnabled,
                      enabled: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Local notification information.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9ECEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: navy,
                      size: 15,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Local reminders work even when the app is closed.',
                        style: TextStyle(
                          color: navy,
                          fontSize: 9,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}