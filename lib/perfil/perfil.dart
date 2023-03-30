import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:repmusic/perfil/editar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

class Perfil extends StatefulWidget {
  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(uid).get();
      final Map<String, dynamic>? data = snapshot.data();
      setState(() {
        _user = user;
        _userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'Perfil',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_user != null) Text('User ID: ${_user!.uid}'),
            if (_userData != null) Text('Name: ${_userData!['nombre']}'),
            if (_userData != null) Text('Email: ${_userData!['email']}'),
            // if (_userData != null) Text('Age: ${_userData!['age']}'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => editData(userData: _userData)));
              },
              style: ElevatedButton.styleFrom(
                primary: colorNav, // Definir el color de fondo del botón aquí
              ),
              child: Text('Editar datos'),
            ),
          ],
        ),
      ),
    );
  }
}
