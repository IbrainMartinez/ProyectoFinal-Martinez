import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart' hide context;
import 'package:repmusic/API/API.dart';
import 'package:repmusic/services/audio_manager.dart';
import 'package:repmusic/widgets/spinner.dart';

class AudioApp extends StatefulWidget {
  @override
  AudioAppState createState() => AudioAppState();
}

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

@override
class AudioAppState extends State<AudioApp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        toolbarHeight: size.height * 0.09,
        title: const Text(
          'Reproduciendo...',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            focusColor: colorNav,
            splashColor: colorNav,
            hoverColor: colorNav,
            highlightColor: colorNav,
            icon: const Icon(
              FluentIcons.chevron_down_20_regular,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30),
        child: StreamBuilder<SequenceState?>(
          stream: audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state?.sequence.isEmpty ?? true) {
              return const SizedBox();
            }
            final metadata = state!.currentSource!.tag;
            final songLikeStatus = ValueNotifier<bool>(
              isSongAlreadyLiked(metadata.extras['ytid']),
            );
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (metadata.extras['localSongId'] is int)
                  QueryArtworkWidget(
                    id: metadata.extras['localSongId'] as int,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(8),
                    artworkQuality: FilterQuality.high,
                    quality: 100,
                    artworkWidth: size.width - 100,
                    artworkHeight: size.width - 100,
                    nullArtworkWidget: Container(
                      width: size.width - 100,
                      height: size.width - 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorAppBar,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FluentIcons.music_note_1_24_regular,
                            size: size.width / 8,
                            color: colorNav,
                          ),
                        ],
                      ),
                    ),
                    keepOldArtwork: true,
                  )
                else
                  SizedBox(
                    width: size.width - 100,
                    height: size.width - 100,
                    child: CachedNetworkImage(
                      imageUrl: metadata.artUri.toString(),
                      imageBuilder: (context, imageProvider) => DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => const Spinner(),
                      errorWidget: (context, url, error) => DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: colorAppBar,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FluentIcons.music_note_1_24_regular,
                              size: size.width / 8,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.04,
                    bottom: size.height * 0.01,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        metadata!.title
                            .toString()
                            .split(' (')[0]
                            .split('|')[0]
                            .trim(),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'RedHatDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B0161),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Text(
                          '${metadata!.artist}',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  child: _buildPlayer(
                    size,
                    songLikeStatus,
                    metadata.extras['ytid'],
                    metadata,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayer(
    Size size,
    ValueNotifier<bool> songLikeStatus,
    dynamic ytid,
    dynamic metadata,
  ) =>
      Container(
        padding: EdgeInsets.only(
          top: size.height * 0.01,
          left: 16,
          right: 16,
          bottom: size.height * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (positionData != null)
                      Slider(
                        activeColor: colorNav,
                        inactiveColor: Colors.green[50],
                        value: positionData.position.inMilliseconds.toDouble(),
                        onChanged: (double? value) {
                          setState(() {
                            audioPlayer.seek(
                              Duration(
                                milliseconds: value!.round(),
                              ),
                            );
                            value = value;
                          });
                        },
                        max: positionData.duration.inMilliseconds.toDouble(),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (positionData != null)
                          Text(
                            positionData.position
                                .toString()
                                .split('.')
                                .first
                                .replaceFirst('0:0', '0'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        if (metadata.extras['ytid'].toString().isNotEmpty)
                          Column(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: songLikeStatus,
                                builder: (_, value, __) {
                                  if (value == true) {
                                    return IconButton(
                                      color: colorNav,
                                      icon: const Icon(
                                        FluentIcons.heart_24_filled,
                                      ),
                                      iconSize: 35,
                                      splashColor: colorNav,
                                      onPressed: () => {
                                        updateLikeStatus(ytid, false),
                                        songLikeStatus.value = false
                                      },
                                    );
                                  } else {
                                    return IconButton(
                                      color: Theme.of(context).hintColor,
                                      icon: const Icon(
                                        FluentIcons.heart_24_regular,
                                      ),
                                      iconSize: 35,
                                      splashColor: colorNav,
                                      onPressed: () => {
                                        updateLikeStatus(ytid, true),
                                        songLikeStatus.value = true
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        if (positionData != null)
                          Text(
                            positionData.duration
                                .toString()
                                .split('.')
                                .first
                                .replaceAll('0:', ''),
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                      ],
                    )
                  ],
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.03),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.arrow_shuffle_24_filled,
                            color: shuffleNotifier.value
                                ? colorNav
                                : Theme.of(context).hintColor,
                          ),
                          iconSize: 20,
                          onPressed: changeShuffleStatus,
                          splashColor: Colors.white,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.previous_24_filled,
                            color: hasPrevious ? colorAppBar : Colors.grey,
                          ),
                          iconSize: 40,
                          onPressed: () async => {
                            await playPrevious(),
                          },
                          splashColor: colorNav,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorNav,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (processingState == ProcessingState.loading ||
                                  processingState ==
                                      ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).hintColor,
                                    ),
                                  ),
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: const Icon(
                                    FluentIcons.play_12_filled,
                                    color: Colors.white,
                                  ),
                                  iconSize: 40,
                                  onPressed: audioPlayer.play,
                                  splashColor: Colors.white,
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return IconButton(
                                  icon: const Icon(
                                    FluentIcons.pause_12_filled,
                                    color: Colors.white,
                                  ),
                                  iconSize: 40,
                                  onPressed: audioPlayer.pause,
                                  splashColor: Colors.white,
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(
                                    FluentIcons.replay_20_filled,
                                    color: colorAppBar,
                                  ),
                                  iconSize: 30,
                                  onPressed: () => audioPlayer.seek(
                                    Duration.zero,
                                    index: audioPlayer.effectiveIndices!.first,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.next_24_filled,
                            color: hasNext ? colorAppBar : Colors.grey,
                          ),
                          iconSize: 40,
                          onPressed: () async => {
                            await playNext(),
                          },
                          splashColor: colorAppBar,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            FluentIcons.arrow_repeat_1_24_filled,
                            color: repeatNotifier.value
                                ? colorNav
                                : Theme.of(context).hintColor,
                          ),
                          iconSize: 20,
                          onPressed: changeLoopStatus,
                          splashColor: colorNav,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
