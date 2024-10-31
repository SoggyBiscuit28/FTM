import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:intl/intl.dart';
// import 'package:osm_nominatim/osm_nominatim.dart';
// import 'package:battery_plus/battery_plus.dart';
import 'credentials.dart' as creds;
import 'package:shared_preferences/shared_preferences.dart';

const String regServerName = "gps.itrackall.in";
const int regPort = 8080;

class LocationService {
  // final Battery _battery = Battery();
  String? requestString;
  String? genString;

  LocationService() {
    configureBackgroundGeolocation();
  }

  void _onLocation(bg.Location location) async {
    print('[location] - $location');

    // int batteryLevel = location.battery.level as int;
    requestString = await createString(
        location.coords.latitude!,
        location.coords.longitude!,
        location.coords.speed!,
        location.coords.heading!,
        69,
        1
    );

    await bg.BackgroundGeolocation.setConfig(bg.Config(

        extras: {
          "_missinglocations": requestString,
        }
    ));

    print('Config was suppose to be updated from onLocation \n String being generated: $requestString');
  }

  Future<void> configureBackgroundGeolocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? deviceName = prefs.getString('deviceName');
    print('The stored userName and device name are $userName and $deviceName');

    bg.BackgroundGeolocation.onLocation(_onLocation, (bg.LocationError error) {
      print('[location] ERROR: $error');
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    bg.BackgroundGeolocation.onActivityChange((bg.ActivityChangeEvent event) {
      print('[activitychange] - $event');
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10.0,
      // locationUpdateInterval: 20000,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: false,
      foregroundService: true,
      notification: bg.Notification(
        title: "App is tracking your location",
        text: "Location tracking enabled",
        priority: Config.NOTIFICATION_PRIORITY_HIGH
      ),
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      url: 'http://$regServerName:$regPort/gprmc/Data?acct=$userName&dev=$deviceName&requesttype=BULK_DATA&requestfrom=flutter',
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      autoSync: true,
      httpRootProperty: ".",
      // locationTemplate: '{"timestamp": "<%= timestamp %>","battery":<%= battery.level %>,"travel_mode":"<%= activity.type %>"}',
    )).then((bg.State state) {
      print('[ready] BackgroundGeolocation is configured and ready to use');
    });

    bg.BackgroundGeolocation.onHttp((bg.HttpEvent event) {
      print('[http] - Status: ${event.status}');
      print('[http] - Response: ${event.responseText}');
    });
  }

  Future<void> startTracking() async {
    print('[startTracking] Attempting to start tracking');
    await bg.BackgroundGeolocation.start().then((bg.State state) {
      print('[startTracking] Tracking started: $state');
    }).catchError((error) {
      print('[startTracking] ERROR: $error');
    });
  }

  Future<void> stopTracking() async {
    print('[stopTracking] Attempting to stop tracking');
    await bg.BackgroundGeolocation.stop().then((bg.State state) {
      print('[stopTracking] Tracking stopped: $state');
    }).catchError((error) {
      print('[stopTracking] ERROR: $error');
    });
    bg.BackgroundGeolocation.removeListeners();
  }

  Future<String> createString(
      double latitude,
      double longitude,
      double speed,
      double heading,
      int battlevel,
      int seq) async {
    String? userevent = "pending::::";
    String uuid = await creds.UniqueIdHelper.getId();

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
    req += "&userevent=" + "Location Service";
    req += "&uuid=" + uuid;
    req += ";";
    print('this is the req string being generated in location service: $req');
    return req;
  }

  Future<String?> getStoredUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<String?> getStoredDeviceName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('deviceName');
  }
}
