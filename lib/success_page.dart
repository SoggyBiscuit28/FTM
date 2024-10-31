import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';
import 'logout_page.dart'; // Import the logout page
import 'credentials.dart' as creds;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeUI(),
    );
  }
}

class HomeUI extends StatelessWidget {
  final LocationService locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Field Task Manager',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/CMW_logo.jpg'),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Terms of Use & Privacy Policy') {
                _launchURL();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Terms of Use & Privacy Policy'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.45, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await locationService.startTracking();
                  // Print UUID to console
                  String uuid = await creds.UniqueIdHelper.getId();
                  print("UUID: $uuid");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LogoutPage(locationService: locationService)));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, color: Colors.white, size: 44),
                    SizedBox(height: 8),
                    Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.48, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 44),
                    SizedBox(height: 8),
                    Text('View Alerts', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              fixedSize: Size(MediaQuery.of(context).size.width * 0.96, 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Logger.emailLog('nerdybisc@gmail.com').then((bool success) {
                print('[emailLog] success');
              }).catchError((error) {
                print('[emailLog] FAILURE: ${error}');
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app, color: Colors.white, size: 44),
                SizedBox(height: 8),
                Text('Close Screen/send email', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL() async {
    final Uri _url = Uri.parse('https://www.connectmyworld.in/privacy-policy/');
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw Exception('Could not launch $_url');
    }
  }
}