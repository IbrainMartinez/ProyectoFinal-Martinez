import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:repmusic/LoginF/login.dart';
import 'package:repmusic/perfil/perfil.dart';

final prefferedFileExtension = ValueNotifier<String>(
  Hive.box('settings').get('audioFileType', defaultValue: 'mp3') as String,
);
final playNextSongAutomatically = ValueNotifier<bool>(
  Hive.box('settings').get('playNextSongAutomatically', defaultValue: false),
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
// const bottomNavigationBar = false;

// mandar para reporte

FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;
String? userEmail = user?.email;

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
      bottomNavigationBar: null,
      body: SingleChildScrollView(child: SettingsCards()),
    );
  }
}

class SettingsCards extends StatelessWidget {
  @override
  String? uid = user?.uid;
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            child: ListTile(
              leading: const Icon(
                FluentIcons.person_24_regular,
                color: colorNav,
              ),
              title: const Text(
                'Perfil',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Perfil(),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            child: ListTile(
              leading: const Icon(
                FluentIcons.shopping_bag_24_filled,
                color: colorNav,
              ),
              title: const Text(
                'Adquirir Suscripción',
              ),
              onTap: () async {
                await pdfInvoiceDownload(
                  context,
                  'Suscripcion',
                  'Gracias por Suscribirte a nuestra aplicación',
                  '999999.99999',
                  uid,
                  userEmail,
                  '10000.0000',
                  'Status',
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            child: ListTile(
              leading: const Icon(
                FluentIcons.lock_shield_24_regular,
                color: colorNav,
              ),
              title: const Text(
                'Cerrar Sesión',
              ),
              onTap: () async {
                // Borrar los valores almacenados en el almacenamiento seguro
                final storage = const FlutterSecureStorage();
                await storage.deleteAll();

                // Después de eliminar los valores, se realiza la lógica para cerrar la sesión.
                // En este caso, estamos cerrando la sesión de FirebaseAuth y navegando a la página de inicio de sesión.
                const CircularProgressIndicator();
                await FirebaseAuth.instance.signOut();
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 6),
          child: Card(
            elevation: 2.0,
            child: ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar eliminación de cuenta'),
                    content: const Text(
                        '¿Estás seguro que quieres eliminar tu cuenta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Llama a la función para eliminar la cuenta
                          await eliminarCuenta();
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text('Eliminar cuenta'),
                      ),
                    ],
                  ),
                );
              },
              title: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: const Text(
                  'Eliminar cuenta',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// funcionest
  Future pdfInvoiceDownload(
    BuildContext context,
    String? title,
    String? equipamento,
    String? implemento,
    String? setor,
    String? local,
    String? responsavel,
    String? status,
  ) async {
    // null safety
    title = title ?? '';
    equipamento = equipamento ?? '';
    implemento = implemento ?? '';
    setor = setor ?? '';
    local = local ?? '';
    responsavel = responsavel ?? '';
    status = status ?? '';

    final pdf = pw.Document();

    //
    final netImage = await networkImage('https://www.nfet.net/nfet.jpg');

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.varelaRoundRegular(),
          bold: await PdfGoogleFonts.varelaRoundRegular(),
          icons: await PdfGoogleFonts.materialIcons(),
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(title ?? '',
                  style: const pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 40,
                  )),
              pw.Divider(thickness: 4),
              pw.SizedBox(height: 10),

              //equipamento
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Icon(pw.IconData(0xea79), size: 25),
                  pw.SizedBox(width: 10),
                  pw.Text('' + (equipamento ?? ''))
                ],
              ),

              //implemento
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Icon(pw.IconData(0xef3d), size: 25),
                  pw.SizedBox(width: 10),
                  pw.Text('Pago: ' + (implemento ?? ''))
                ],
              ),

              //setor
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Icon(pw.IconData(0xe0b8), size: 25),
                  pw.SizedBox(width: 10),
                  pw.Text('ID: ' + (setor ?? ''))
                ],
              ),

              //local

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Icon(pw.IconData(0xe55e), size: 25),
                  pw.SizedBox(width: 10),
                  pw.Text('Correo: ' + (local ?? ''))
                ],
              ),

              //responsável
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Icon(pw.IconData(0xe7fd), size: 10),
                  pw.SizedBox(width: 10),
                  pw.Text('Inpuesto: ' + (responsavel ?? ''))
                ],
              ),
            ],
          );
        },
      ),
    );

    final pdfSaved = await pdf.save();

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfSaved);
  }

  Future<void> eliminarCuenta() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print('Error al eliminar la cuenta: $e');
    }
  }
}
