import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class ReminderItem {
  int id;
  String title;
  String note;
  int hour;
  int minute;
  bool enabled;

  ReminderItem({required this.id, required this.title, this.note = '', required this.hour, required this.minute, this.enabled = true});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
      };

  factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
        id: json['id'],
        title: json['title'],
        note: json['note'] ?? '',
        hour: json['hour'],
        minute: json['minute'],
        enabled: json['enabled'] ?? true,
      );
}

class _RemindersPageState extends State<RemindersPage> {
  List<ReminderItem> _reminders = [];
  final String _prefsKey = 'vitatrack_reminders_v1';

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        _reminders = decoded.map((e) => ReminderItem.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_reminders.map((r) => r.toJson()).toList()));
  }

  Future<void> _addReminder() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    TimeOfDay? pickedTime;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: noteController, decoration: InputDecoration(labelText: 'Note (optional)')),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
                if (t != null) pickedTime = TimeOfDay(hour: t.hour, minute: t.minute);
                setState(() {});
              },
              child: Text(pickedTime == null ? 'Pick Time' : 'Time: ${pickedTime!.hour}:${pickedTime!.minute.toString().padLeft(2, '0')}'),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty || pickedTime == null) return;
              final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
              final reminder = ReminderItem(id: id, title: titleController.text.trim(), note: noteController.text.trim(), hour: pickedTime!.hour, minute: pickedTime!.minute);
              setState(() => _reminders.add(reminder));
              await _saveReminders();
              await NotificationService().scheduleDailyNotification(
                id: reminder.id,
                title: reminder.title,
                body: reminder.note.isEmpty ? 'Time to measure / take medication' : reminder.note,
                time: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleReminder(ReminderItem r) async {
    setState(() => r.enabled = !r.enabled);
    await _saveReminders();
    if (r.enabled) {
      await NotificationService().scheduleDailyNotification(
        id: r.id,
        title: r.title,
        body: r.note.isEmpty ? 'Time to measure / take medication' : r.note,
        time: TimeOfDay(hour: r.hour, minute: r.minute),
      );
    } else {
      await NotificationService().cancelNotification(r.id);
    }
  }

  Future<void> _deleteReminder(ReminderItem r) async {
    setState(() => _reminders.removeWhere((e) => e.id == r.id));
    await _saveReminders();
    await NotificationService().cancelNotification(r.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminders'), backgroundColor: Colors.teal),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
        onPressed: _addReminder,
      ),
      body: _reminders.isEmpty
          ? Center(child: Text('No reminders yet. Tap + to add.'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, i) {
                final r = _reminders[i];
                return ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')} — ${r.note}'),
                  trailing: Wrap(spacing: 8, children: [
                    Switch(value: r.enabled, onChanged: (_) => _toggleReminder(r)),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteReminder(r)),
                  ]),
                );
              },
            ),
    );
  }
}
