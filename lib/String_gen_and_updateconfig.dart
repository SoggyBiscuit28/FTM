import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:battery_plus/battery_plus.dart' as bp;
import 'package:intl/intl.dart';
// import 'package:osm_nominatim/osm_nominatim.dart';
import 'credentials.dart';

String? requestString;
final bp.Battery _battery = bp.Battery();

Future<void> updateConfigString(bg.Location location) async{
  int batteryLevel = await Battery().batteryLevel;
  String requestString = createString(
      location.coords.latitude!,
      location.coords.longitude!,
      location.coords.speed!,
      location.coords.heading!,
      batteryLevel,
      1
  ) as String;

  print('Config was suppose to be updated \n String being generated: $requestString');

  // Update configuration dynamically
  await bg.BackgroundGeolocation.setConfig(bg.Config(
      extras: {
        "_missingLocations": requestString,
      }
  ));
}

Future<String> createString(
    double latitude,
    double longitude,
    double speed,
    double heading,
    int battlevel,
    int seq) async {
  String? userevent = "pending::::";
  String uuid = await UniqueIdHelper.getId();

  // final reverseGeocode = await Nominatim.reverseSearch(lat: latitude, lon: longitude);
  // final address = reverseGeocode.displayName;
  //
  // userevent = address != null ? "$address " : "";

  DateTime now = DateTime.now().toUtc();
  String req = "";
  req += "dt=${DateFormat('yyyyMMdd').format(now)}";
  req += "&tm=${DateFormat('HHmmss').format(now)}";
  req += "&lat=" + latitude.toString();
  req += "&lon=" + longitude.toString();
  req += "&kph=" + (speed * 3.6).toString();
  req += "&heading=" + heading.toString();
  req += "&battlevel=" + battlevel.toString();
  req += "&seq=" + seq.toString();
  req += "&userevent=" + "Ecks Dee";
  req += "&uuid=" + uuid;
  req += ";";
  print('this is the req string being generated : $req');
  return req;
}