import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'alarm_callback.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<Map<String, dynamic>> alarms = [];

  final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];

  @override
  void initState() {
    super.initState();
    loadAlarms();
  }

  /// 💾 SAVE
  Future<void> saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("alarms", jsonEncode(alarms));
  }

  /// 🔄 LOAD
  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("alarms");

    if (data != null) {
      final decoded = jsonDecode(data);

      alarms = List<Map<String, dynamic>>.from(
        decoded.map((e) {
          return {
            "id": e["id"],
            "hour": e["hour"],
            "minute": e["minute"],
            "days": List<bool>.from(e["days"]),
            "isOn": e["isOn"],
            "type": e["type"] ?? "weekly",
            "label": e["label"] ?? "Alarm",
          };
        }),
      );

      setState(() {});
    }
  }

  /// 🔔 ADD
  Future<void> addAlarm() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 0),
    );

    if (picked == null) return;

    int id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    Map<String, dynamic> newAlarm = {
      "id": id,
      "hour": picked.hour,
      "minute": picked.minute,
      "days": List.generate(7, (_) => true),
      "isOn": true,
      "type": "weekly",
      "label": "Gym 💪",
    };

    alarms.add(newAlarm);

    await scheduleWeeklyAlarm(
      hour: picked.hour,
      minute: picked.minute,
      days: List<bool>.from(newAlarm["days"]),
      alarmId: id,
    );

    await saveAlarms();
    setState(() {});
  }

  /// 🔁 WEEKLY
  Future<void> scheduleWeeklyAlarm({
    required int hour,
    required int minute,
    required List<bool> days,
    required int alarmId,
  }) async {
    for (int i = 0; i < 7; i++) {
      if (!days[i]) continue;

      DateTime now = DateTime.now();
      int today = now.weekday;
      int target = i + 1;

      int diff = target - today;
      if (diff < 0) diff += 7;

      DateTime time = DateTime(
        now.year,
        now.month,
        now.day + diff,
        hour,
        minute,
      );

      if (time.isBefore(now)) {
        time = time.add(const Duration(days: 7));
      }

      await AndroidAlarmManager.oneShotAt(
        time,
        alarmId + i,
        alarmCallback,
        exact: true,
        wakeup: true,
      );
    }
  }

  /// 🔁 DAILY
  Future<void> scheduleDailyAlarm({
    required int hour,
    required int minute,
    required int alarmId,
  }) async {
    DateTime now = DateTime.now();

    DateTime time = DateTime(now.year, now.month, now.day, hour, minute);

    if (time.isBefore(now)) {
      time = time.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      alarmId,
      alarmCallback,
      startAt: time,
      exact: true,
      wakeup: true,
    );
  }

  /// 🔘 TOGGLE
  Future<void> toggleAlarm(int index, bool value) async {
    final alarm = alarms[index];
    int id = alarm["id"];

    alarm["isOn"] = value;

    if (value) {
      if (alarm["type"] == "daily") {
        await scheduleDailyAlarm(
          hour: alarm["hour"],
          minute: alarm["minute"],
          alarmId: id,
        );
      } else {
        await scheduleWeeklyAlarm(
          hour: alarm["hour"],
          minute: alarm["minute"],
          days: List<bool>.from(alarm["days"]),
          alarmId: id,
        );
      }
    } else {
      for (int i = 0; i < 7; i++) {
        await AndroidAlarmManager.cancel(id + i);
      }
    }

    await saveAlarms();
    setState(() {});
  }

  /// ❌ DELETE
  Future<void> deleteAlarm(int index) async {
    int id = alarms[index]["id"];

    for (int i = 0; i < 7; i++) {
      await AndroidAlarmManager.cancel(id + i);
    }

    alarms.removeAt(index);
    await saveAlarms();
    setState(() {});
  }

  /// 🧩 UI TILE
  Widget alarmTile(int index) {
    final alarm = alarms[index];

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: alarm["hour"], minute: alarm["minute"]),
        );

        if (picked == null) return;

        alarm["hour"] = picked.hour;
        alarm["minute"] = picked.minute;

        await toggleAlarm(index, false);
        await toggleAlarm(index, true);

        await saveAlarms();
        setState(() {});
      },
      onLongPress: () => deleteAlarm(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: alarm["isOn"]
                ? [Color(0xFF2A3F0A), Color(0xFF1C2E05)]
                : [Color(0xFF232526), Color(0xFF0F2027)],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TimeOfDay(
                    hour: alarm["hour"],
                    minute: alarm["minute"],
                  ).format(context),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: alarm["isOn"],
                  onChanged: (v) => toggleAlarm(index, v),
                  activeThumbColor: const Color(0xFFD0FD3E),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// LABEL
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                alarm["label"],
                style: const TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 10),

            /// DAYS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      alarm["days"][i] = !alarm["days"][i];
                    });

                    if (alarm["isOn"]) {
                      await toggleAlarm(index, false);
                      await toggleAlarm(index, true);
                    }

                    await saveAlarms();
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: alarm["days"][i]
                        ? const Color(0xFFD0FD3E)
                        : Colors.transparent,
                    child: Text(
                      days[i],
                      style: TextStyle(
                        color: alarm["days"][i] ? Colors.black : Colors.white70,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C2E05), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Alarm "),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: alarms.isEmpty
              ? const Center(child: Text("No alarms"))
              : ListView.builder(
                  itemCount: alarms.length,
                  itemBuilder: (_, i) => alarmTile(i),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFD0FD3E),
          onPressed: addAlarm,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
