import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:repmusic/LoginF/register.dart';
import 'package:repmusic/screens/more_page.dart';
import 'package:repmusic/services/audio_manager.dart';

GetIt getIt = GetIt.instance;
bool _interrupted = false;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Register(),
      // home: Repmusic(),
    );
  }
}

void main() async {
  await initialisation();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

Future<void> initialisation() async {
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('user');
  await Hive.openBox('cache');

  await FlutterDisplayMode.setHighRefreshRate();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ibramr.repmusic',
    androidNotificationChannelName: 'RepMusic',
    androidNotificationIcon: 'mipmap/launcher_icon',
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: !foregroundService.value,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  session.interruptionEventStream.listen((event) {
    if (event.begin) {
      if (audioPlayer.playing) {
        audioPlayer.pause();
        _interrupted = true;
      }
    } else {
      switch (event.type) {
        case AudioInterruptionType.pause:
        case AudioInterruptionType.duck:
          if (!audioPlayer.playing && _interrupted) {
            audioPlayer.play();
          }
          break;
        case AudioInterruptionType.unknown:
          break;
      }
      _interrupted = false;
    }
  });
  activateListeners();
  await enableBooster();
}
