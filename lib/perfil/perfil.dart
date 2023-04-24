import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repmusic/perfil/editar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;
final ImagePicker _picker = ImagePicker();

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

  Future<String?> _getImageUrl() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final Reference ref = _storage.ref().child('users/$uid/profile.jpg');
      try {
        final String url = await ref.getDownloadURL();
        return url;
      } catch (e) {
        print('Error al obtener la URL de la imagen: $e');
        return null;
      }
    }
    return null;
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

  Future<void> _uploadImage() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String uid = user.uid;
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final Reference ref = _storage.ref().child('users/$uid/profile.jpg');
        final UploadTask task = ref.putFile(file);
        await task.whenComplete(
            () => print('Image uploaded to Firebase Cloud Storage'));
      }
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
            FutureBuilder<String?>(
              future: _getImageUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Icon(Icons.error_outline);
                }
                final imageUrl = snapshot.data!;
                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorAppBar,
                      width: 5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Column(
              children: [
                if (_userData != null)
                  Text(
                    '${_userData!['nombre']}',
                    style: const TextStyle(
                      fontSize: 24, // tamaño de fuente más grande
                      fontWeight: FontWeight.bold,
                      color: colorNav, // fuente en negrita
                    ),
                  ),
                if (_user != null)
                  Text(
                    'User ID: ${_user!.uid}',
                    textAlign: TextAlign.center, // texto centrado
                    style: TextStyle(
                      fontSize: 12, // tamaño de fuente más pequeño
                    ),
                  ),
                if (_userData != null)
                  Text(
                    'Email: ${_userData!['email']}',
                    textAlign: TextAlign.center, // texto centrado
                    style: TextStyle(
                      fontSize: 12, // tamaño de fuente igual que el anterior
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                SizedBox(width: 30),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      primary: colorAppBar,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // borde redondeado
                      ),
                    ),
                    child: Text('Subir imagen'),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => editData(userData: _userData),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: colorNav,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // borde redondeado
                      ),
                    ),
                    child: Text('Editar datos'),
                  ),
                ),
                SizedBox(width: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
