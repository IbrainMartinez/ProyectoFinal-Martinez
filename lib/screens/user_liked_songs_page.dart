import 'package:flutter/material.dart';
import 'package:repmusic/API/API.dart';
import 'package:repmusic/widgets/song_bar.dart';

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

class UserLikedSongs extends StatefulWidget {
  const UserLikedSongs({super.key});

  @override
  State<UserLikedSongs> createState() => _UserLikedSongsState();
}

class _UserLikedSongsState extends State<UserLikedSongs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'Musica que te gusta',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        'Tus Musicas',
                        style: TextStyle(
                          color: Color(0xFF1B0161),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(top: 5, bottom: 5),
                      ),
                      ElevatedButton(
                        onPressed: () => {
                          setActivePlaylist(
                            {
                              'ytid': '',
                              'title': 'info',
                              'header_desc': '',
                              'image': '',
                              'list': userLikedSongsList
                            },
                          ),
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(colorNav),
                          fixedSize:
                              MaterialStateProperty.all<Size>(const Size(325, 50)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Reproducir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontFamily: 'RedHatDisplay',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              itemCount: userLikedSongsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: SongBar(
                    userLikedSongsList[index],
                    true,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
