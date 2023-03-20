import 'package:url_launcher/url_launcher.dart';

void launchURL(url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo ejecutar $url';
  }
}
