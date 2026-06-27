import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../state/wallet_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('wallet_channel', 'Wallet Notifications',
            importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> runPredictiveAnalysis(WalletState state) async {
    // Check if balance goes below 400 within 30 days
    final timeline = state.calculateForecastTimeline(30);
    final now = DateTime.now();

    for (int i = 0; i < timeline.length; i++) {
      if (timeline[i] < 400.0) {
        // Trigger alert
        final alertDate = now.add(Duration(days: i + 1));
        final dateStr = DateFormat('dd MMM', 'it_IT').format(alertDate);
        await showNotification(
          'Attenzione al Saldo',
          'Secondo le nostre stime, se mantieni questo trend di spesa potresti scendere sotto la tua soglia di sicurezza di €400 il $dateStr.',
        );
        break; // Only one alert
      }
    }
  }
}
