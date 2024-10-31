import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'success_page.dart'; // Import the HomePage
import 'credentials.dart' as creds;

const String regServerName = "connectmyworld.in";
const int regPort = 80;

Future<String> sendAndReceive(String finalUrl, bool onlySuccess) async {
  try {
    final response = await http.post(Uri.parse(finalUrl)).timeout(Duration(seconds: 5));
    print('Server request: ${Uri.parse(finalUrl)}');
    print('Server response status: ${response.statusCode}');
    print('Server response body: ${response.body}');

    if (response.statusCode == 200 || !onlySuccess) {
      return response.body;
    }
  } catch (e) {
    print('Error: $e');
    if (!onlySuccess) {
      return e.toString();
    }
  }
  return "";
}

void afterRegistrationAttempt(BuildContext context, String userName, String password, String deviceName, String response) {
  print('Response in afterRegistrationAttempt: $response');

  if (response.isNotEmpty) {
    final messages = response.split(":");
    if (messages[0] == "1") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Status'),
            content: Text(messages[2]),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () async {
                  if (messages[2].toLowerCase().contains("Device id already exist".toLowerCase())) {
                    final newUrl = "http://$regServerName:$regPort/Track/gts.php?username=$userName&password=$password&device_name=$deviceName&duplicate_device=true&uuid=${await creds.UniqueIdHelper.getId()}";
                    String result = await sendAndReceive(newUrl, true);

                    if (result == "success") {
                      creds.saveDetails(userName, deviceName);
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else if (result == "fail") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Technical Issue, try later or contact us for technical support.")));
                    }
                  } else {
                    creds.saveDetails(userName, deviceName);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registration Status'),
            content: Text(messages[1]),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connection Failed'),
          content: Text("Fail to connect to server. Try again, Make sure internet connection is available"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Future<void> saveDetails(String userName, String deviceName) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
//   prefs.setString('userName', userName);
//   prefs.setString('deviceName', deviceName);
//   String uniqueID = Uuid().v4();
//   if (uniqueID.length > 10) {
//     uniqueID = uniqueID.substring(0, 10);
//   }
//   await prefs.setString('PREF_UNIQUE_ID', uniqueID);
//   print("Stored UUID: $uniqueID");
// }
//
// class UniqueIdHelper {
//   static const String PREF_UNIQUE_ID = 'PREF_UNIQUE_ID';
//   static String? uniqueID;
//
//   static Future<String> getId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (uniqueID == null) {
//       uniqueID = prefs.getString(PREF_UNIQUE_ID);
//       if (uniqueID == null) {
//         uniqueID = Uuid().v4();
//         if (uniqueID!.length > 10) {
//           uniqueID = uniqueID!.substring(0, 10);
//         }
//         await prefs.setString(PREF_UNIQUE_ID, uniqueID!);
//         print("Stored UUID: $uniqueID");
//       }
//     }
//     return uniqueID!;
//   }
// }

// Future<String?> getStoredUserName() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('userName');
// }
//
// Future<String?> getStoredDeviceName() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('deviceName');
// }
//
// Future<String?> getStoredUUID() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString(UniqueIdHelper.PREF_UNIQUE_ID);
// }

