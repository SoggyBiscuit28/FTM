import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<void> saveDetails(String userName, String deviceName) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Clear existing preferences before saving new details
  // await prefs.clear();

  // Save user details
  prefs.setString('userName', userName);
  prefs.setString('deviceName', deviceName);

  // Ensure UUID is generated and stored only once
  String? uniqueID = await UniqueIdHelper.getId();

  // Print the stored UUID to the console
  print("Stored UUID in saveDetails: $uniqueID");
}

class UniqueIdHelper {
  static const String PREF_UNIQUE_ID = 'PREF_UNIQUE_ID';
  static String? uniqueID;

  static Future<String> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (uniqueID == null) {
      uniqueID = prefs.getString(PREF_UNIQUE_ID);

      if (uniqueID == null) {
        uniqueID = Uuid().v4();
        if (uniqueID!.length > 10) {
          uniqueID = uniqueID!.substring(0, 10);
        }

        await prefs.setString(PREF_UNIQUE_ID, uniqueID!);
        // Print the stored UUID to the console
        print("Stored UUID in uniqueIdHelper: $uniqueID");
      }
    }

    return uniqueID!;
  }
}

// Add these getter functions

Future<String?> getStoredUserName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}

Future<String?> getStoredDeviceName() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('deviceName');
}

Future<String?> getStoredUUID() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(UniqueIdHelper.PREF_UNIQUE_ID);
}
