import 'package:url_launcher/url_launcher_string.dart';

class MapLauncher {
  showMap(lat, long) async {
    final url = 'https://maps.google.com/?q=$lat,$long';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
