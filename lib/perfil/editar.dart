import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class editData extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const editData({Key? key, this.userData}) : super(key: key);

  @override
  _editDataState createState() => _editDataState();
}

const colorNav = Color(0xFF1B0161);
const colorAppBar = Color(0xFF6052a6);

class _editDataState extends State<editData> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _ageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['nombre'];
      _emailController.text = widget.userData!['email'];
      // _ageController.text = widget.userData!['age'].toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      final users = _firestore.collection('users');
      final userDoc = users.doc(uid);
      final data = <String, dynamic>{
        'nombre': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        // 'age': int.tryParse(_ageController.text.trim()) ?? 0,
      };
      await userDoc.set(data, SetOptions(merge: true));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorAppBar,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 16.0),
            // TextFormField(
            //   controller: _ageController,
            //   decoration: InputDecoration(labelText: 'Edad'),
            //   keyboardType: TextInputType.number,
            // ),
            SizedBox(height: 16.0),
            // ElevatedButton(
            //   onPressed: _updateUserData,
            //   style: ElevatedButton.styleFrom(
            //     primary: colorNav, // Definir el color de fondo del botón aquí
            //   ),
            //   child: const Text(
            //     'Guardar cambios',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 15,
            //       fontFamily: 'RedHatDisplay',
            //     ),
            //   ),
            // ),
            ElevatedButton(
              onPressed: () async {
                await _updateUserData();
                Navigator.pop(
                    context, true,); // Indicar que se guardaron los cambios
              },
              style: ElevatedButton.styleFrom(
                primary: colorNav, // Definir el color de fondo del botón aquí
              ),
              child: const Text(
                'Guardar cambios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'RedHatDisplay',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
