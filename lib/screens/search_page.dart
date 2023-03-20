import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:repmusic/API/API.dart';
import 'package:repmusic/widgets/song_bar.dart';
import 'package:repmusic/widgets/spinner.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchBar = TextEditingController();
  final ValueNotifier<bool> _fetchingSongs = ValueNotifier(false);
  final FocusNode _inputNode = FocusNode();
  List _searchResult = [];

  Future<void> search() async {
    final query = _searchBar.text;

    if (query.isEmpty) {
      _searchResult = [];
      setState(() {});
      return;
    }

    if (!_fetchingSongs.value) {
      _fetchingSongs.value = true;
    }

    try {
      _searchResult = await fetchSongsList(query);
    } catch (e) {
      debugPrint('Error while searching online songs: $e');
    }

    if (_fetchingSongs.value) {
      _fetchingSongs.value = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'Buscar',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 20,
                left: 16,
                right: 12,
              ),
              child: TextField(
                textInputAction: TextInputAction.search,
                controller: _searchBar,
                focusNode: _inputNode,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1B0161),
                ),
                cursorColor: const Color(0xFF6052a6),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 42, 40, 49)),
                  ),
                  suffixIcon: ValueListenableBuilder<bool>(
                    valueListenable: _fetchingSongs,
                    builder: (_, value, __) {
                      return IconButton(
                        icon: value == true
                            ? const SizedBox(
                                height: 18,
                                width: 2000,
                                child: Spinner(),
                              )
                            : const Icon(
                                FluentIcons.search_20_regular,
                                color: Color(0xFF1B0161),
                              ),
                        color: value == true ? colorNav : Colors.white,
                        onPressed: () {
                          search();
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      );
                    },
                  ),
                  hintText: 'Buscando...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Quicksand',
                    color: Color(0xFF6052a6),
                  ),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResult.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: SongBar(
                    _searchResult[index],
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
