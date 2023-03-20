import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:repmusic/screens/user_liked_songs_page.dart';
import 'package:repmusic/widgets/setting_bar.dart';

final prefferedFileExtension = ValueNotifier<String>(
  Hive.box('settings').get('audioFileType', defaultValue: 'mp3') as String,
);
final playNextSongAutomatically = ValueNotifier<bool>(
  Hive.box('settings').get('playNextSongAutomatically', defaultValue: false),
);

final useSystemColor = ValueNotifier<bool>(
  Hive.box('settings').get('useSystemColor', defaultValue: true),
);

final foregroundService = ValueNotifier<bool>(
  Hive.box('settings').get('foregroundService', defaultValue: false) as bool,
);

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'Ajustes',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SingleChildScrollView(child: SettingsCards()),
    );
  }
}

class SettingsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // CATEGORY: PAGES
        SettingBar(
          'Perfil',
          FluentIcons.heart_24_regular,
          () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserLikedSongs()),
            ),
          },
        ),
      ],
    );
  }
}
