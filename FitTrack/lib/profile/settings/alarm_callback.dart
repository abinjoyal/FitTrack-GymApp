import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔥 MUST be top-level
@pragma('vm:entry-point')
void alarmCallback() async {
  /// 🔊 PLAY SOUND (assets)
  final player = AudioPlayer();
  await player.play(AssetSource('music/alarm.mp3'));

  /// 🔔 SHOW NOTIFICATION
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    channelDescription: 'Alarm alert',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
     sound: RawResourceAndroidNotificationSound('alarm'),
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: '⏰ Alarm',
    body: 'Wake up!',
    notificationDetails: details,
  );
}
