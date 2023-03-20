import 'package:flutter/material.dart';

import 'package:repmusic/API/API.dart';
import 'package:repmusic/widgets/song_bar.dart';
import 'package:repmusic/widgets/spinner.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'RepMusic.',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FutureBuilder(
              future: get10Music('PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx'),
              builder: (context, data) {
                if (data.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(35),
                      child: Spinner(),
                    ),
                  );
                }
                if (data.hasError) {
                  return const Center(
                    child: Text(
                      'Error!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
                if (!data.hasData) {
                  return const Center(
                    child: Text(
                      'Nothing Found!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }
                return Wrap(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 55,
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: const Text(
                        'Musica Recomendada',
                        style: TextStyle(
                          color: Color(0xFF1B0161),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        physics: const BouncingScrollPhysics(),
                        itemCount: (data as dynamic).data.length as int,
                        itemBuilder: (context, index) {
                          return SongBar((data as dynamic).data[index], true);
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
