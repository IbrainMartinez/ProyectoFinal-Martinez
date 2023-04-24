import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart' hide context;
import 'package:repmusic/LoginF/login.dart';
import 'package:repmusic/screens/home_page.dart';

import 'package:repmusic/screens/player.dart';
import 'package:repmusic/screens/search_page.dart';
import 'package:repmusic/screens/user_liked_songs_page.dart';
import 'package:repmusic/services/audio_manager.dart';
import 'package:repmusic/widgets/custom_animated_bottom_bar.dart';

class Repmusic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

ValueNotifier<int> activeTabIndex = ValueNotifier<int>(0);
ValueNotifier<String> activeTab = ValueNotifier<String>('/');
final _navigatorKey = GlobalKey<NavigatorState>();

class AppState extends State<Repmusic> {
  @override
  void initState() {
    super.initState();
    // checkNecessaryPermissions(context);
  }

  final Color colorNav = const Color(0xFF1B0161);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_navigatorKey.currentState!.canPop() &&
              _navigatorKey.currentState != null) {
            _navigatorKey.currentState?.pop();
            return false;
          }
          return true;
        },
        child: Navigator(
          key: _navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case '/':
                builder = (BuildContext context) => HomePage();
                break;
              case '/search':
                builder = (BuildContext context) => SearchPage();
                break;
              case '/userListMusic':
                builder = (BuildContext context) => const UserLikedSongs();
                break;  
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute(
              builder: builder,
              settings: settings,
            );
          },
        ),
      ),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getFooter() {
    final items = List.generate(
      3,
      (index) {
        final iconData = [
          FluentIcons.home_24_regular,
          FluentIcons.search_24_regular,
          FluentIcons.heart_24_regular,
        ][index];

        final titles = [
          'Inicio',
          'Buscador',
          'Favoritos',
        ][index];

        final routeName = [
          '/',
          '/search',
          '/userListMusic',
        ][index];

        return BottomNavBarItem(
          icon: Icon(
            iconData,
            color: Colors.white,
          ),
          title: Text(
            titles,
            style: const TextStyle(
              fontFamily: 'RedHatDisplay',
            ),
          ),
          routeName: routeName,
          activeColor: Colors.white,
          inactiveColor: Theme.of(context).hintColor,
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            final metadata = state!.currentSource!.tag;
            return Container(
              height: 75,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 2),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioApp(),
                      ),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                          bottom: 7,
                          right: 19,
                          left: 15,
                        ),
                        child: metadata.extras['localSongId'] is int
                            ? QueryArtworkWidget(
                                id: metadata.extras['localSongId'] as int,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(30),
                                artworkWidth: 60,
                                artworkHeight: 60,
                                artworkFit: BoxFit.cover,
                                nullArtworkWidget: const Icon(
                                  FluentIcons.music_note_1_24_regular,
                                  size: 30,
                                  color: Color(0xFF1B0161),
                                ),
                                keepOldArtwork: true,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CachedNetworkImage(
                                  imageUrl: metadata!.artUri.toString(),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1B0161),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Icon(
                                          FluentIcons.music_note_1_24_regular,
                                          size: 30,
                                          color: Color(0xFF1B0161),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            metadata!.title.toString().length > 15
                                ? '${metadata!.title.toString().substring(0, 15)}...'
                                : metadata!.title.toString(),
                            style: const TextStyle(
                              color: Color(0xFF1B0161),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            metadata!.artist.toString().length > 15
                                ? '${metadata!.artist.toString().substring(0, 15)}...'
                                : metadata!.artist.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: StreamBuilder<PlayerState>(
                          stream: audioPlayer.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final processingState =
                                playerState?.processingState;
                            final playing = playerState?.playing;
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.all(8),
                                width: MediaQuery.of(context).size.width * 0.08,
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1B0161),
                                  ),
                                ),
                              );
                            } else if (playing != true) {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.play_12_filled,
                                  color: colorNav,
                                ),
                                iconSize: 35,
                                onPressed: audioPlayer.play,
                                // splashColor: Colors.grey,
                              );
                            } else if (processingState !=
                                ProcessingState.completed) {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.pause_12_filled,
                                  color: colorNav,
                                ),
                                iconSize: 35,
                                onPressed: audioPlayer.pause,

                                // splashColor: Colors.grey,
                              );
                            } else {
                              return IconButton(
                                icon: Icon(
                                  FluentIcons.replay_20_filled,
                                  color: colorNav,
                                ),
                                iconSize: 35,
                                onPressed: () => audioPlayer.seek(
                                  Duration.zero,
                                  index: audioPlayer.effectiveIndices!.first,
                                ),
                                // splashColor: Colors.grey,
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        _buildBottomBar(context, items),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, List<BottomNavBarItem> items) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 5000),
        height: 75,
        child: CustomAnimatedBottomBar(
          backgroundColor: colorNav,
          selectedIndex: activeTabIndex.value,
          onItemSelected: (index) => setState(() {
            activeTabIndex.value = index; //indica la posicion del nav
            _navigatorKey.currentState!.pushReplacementNamed(activeTab.value);
          }),
          items: items,
        ),
      ),
    );
  }
}
