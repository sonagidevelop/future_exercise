import 'package:geolocator/geolocator.dart';

class Init {
  static Future initialize() async {
    List ll = await _registerServices();
    await _loadSettings();
    return ll;
  }

  static _registerServices() async {
    List longlati = [];
    print("hello");
    await Future.delayed(Duration(seconds: 1));
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String long = position.longitude.toString();
    String lati = position.latitude.toString();
    longlati.add(long);
    longlati.add(lati);
    return longlati;
  }

  static _loadSettings() async {
    print("world");
  }
}
