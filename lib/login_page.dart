import 'package:flutter/material.dart';
import 'package:login_page/registration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'registration.dart' as reg; // Add this prefix
import 'modularity.dart';
import 'form_widgets.dart';
import 'custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'success_page.dart'; // Import the HomePage
import 'credentials.dart' as creds; // Add this prefix

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _deviceIdFocusNode = FocusNode();
  String? _emailError;
  String? _passwordError;
  String? _deviceIdError;
  bool _isDisclaimerShown = false;

  @override
  void initState() {
    super.initState();
    _checkStoredCredentials();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordController.addListener(_onPasswordChange);
    _deviceIdController.addListener(_onDeviceIdChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _deviceIdController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _passwordController.removeListener(_onPasswordChange);
    _deviceIdController.removeListener(_onDeviceIdChange);
    _passwordFocusNode.dispose();
    _deviceIdFocusNode.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      _validateEmail();
    }
  }

  void _onPasswordChange() {
    if (_passwordError != null) {
      setState(() {
        _passwordError = null;
      });
    }
  }

  void _onDeviceIdChange() {
    if (_deviceIdError != null) {
      setState(() {
        _deviceIdError = null;
      });
    }
  }

  void _validateEmail() {
    final email = _emailController.text;
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      if (email.isEmpty) {
        _emailError = null;
      } else if (!regex.hasMatch(email)) {
        _emailError = 'Invalid email ID';
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _checkStoredCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserName = prefs.getString('userName');
    String? storedDeviceName = prefs.getString('deviceName');

    if (storedUserName != null && storedUserName.isNotEmpty && storedDeviceName != null && storedDeviceName.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _requestOverlayPermission() async {
    var status = await Permission.systemAlertWindow.status;
    if (status.isGranted) {
      _requestLocationPermission();
    } else {
      _showPermissionExplanationDialog(Permission.systemAlertWindow, 'Display over other apps');
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _requestNotificationPermission();
    } else {
      _showLocationPermissionDialog();
    }
  }

  Future<void> _requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) {
      _showDisclaimerDialog();
    } else {
      _showPermissionExplanationDialog(Permission.notification, 'Notifications');
    }
  }

  void _showPermissionExplanationDialog(Permission permission, String permissionName) {
    String content = 'The app needs "$permissionName" permission to function correctly. Please grant this permission in the next prompt.';
    if (permission == Permission.location) {
      content = 'The app requires access to your location to provide its services effectively. Please grant "Allow only while using the app" permission in the next prompt.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Permission Required',
          content: content,
          buttonText1: 'Cancel',
          onPressedButton1: () {
            Navigator.of(context).pop();
          },
          buttonText2: 'Proceed',
          onPressedButton2: () async {
            Navigator.of(context).pop();
            if (await permission.request().isGranted) {
              if (permission == Permission.systemAlertWindow) {
                _requestLocationPermission();
              } else if (permission == Permission.location) {
                _requestNotificationPermission();
              } else {
                _showDisclaimerDialog();
              }
            } else {
              await openAppSettings();
              if (await permission.isGranted) {
                if (permission == Permission.systemAlertWindow) {
                  _requestLocationPermission();
                } else if (permission == Permission.location) {
                  _requestNotificationPermission();
                } else {
                  _showDisclaimerDialog();
                }
              } else {
                _showPermissionExplanationDialog(permission, permissionName);
              }
            }
          },
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Permission Required',
          content: 'The app requires access to your location to provide its services effectively. Please grant "Allow only while using the app" permission in the next prompt.',
          buttonText1: 'Cancel',
          onPressedButton1: () {
            Navigator.of(context).pop();
          },
          buttonText2: 'Proceed',
          onPressedButton2: () async {
            Navigator.of(context).pop();
            if (await Permission.location.request().isGranted) {
              _requestNotificationPermission();
            } else {
              await openAppSettings();
              if (await Permission.location.isGranted) {
                _requestNotificationPermission();
              } else {
                _showLocationPermissionDialog();
              }
            }
          },
        );
      },
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Disclaimer',
          content: 'Field Task Manager app is designed for corporate employee use.\n\nAfter Login, this app will need to access location even if the app is closed, or not in use until the employee presses Logout. Location data collected will be used for:\n\n1. Ensuring Safety & Security of the employees when on field related work.\n\n2. Calculating total distance travelled and complete route covered by the employee from Login till Logout.\n\n3. Efficient work allocation based on current location of the employees.',
          buttonText1: 'Decline',
          onPressedButton1: () {
            Navigator.of(context).pop();
          },
          buttonText2: 'Agree',
          onPressedButton2: () async {
            Navigator.of(context).pop();
            await _attemptRegistration();
          },
        );
      },
    );
  }

  Future<void> _attemptRegistration() async {
    final userName = _emailController.text;
    final password = _passwordController.text;
    final deviceName = _deviceIdController.text;
    final url = "http://$regServerName:$regPort/Track/gts.php?username=$userName&password=$password&device_name=$deviceName&uuid=${await creds.UniqueIdHelper.getId()}";

    print('Attempting registration with URL: $url'); // Print the input URL

    final response = await sendAndReceive(url, true);

    print('Server response: $response'); // Print the server response

    afterRegistrationAttempt(context, userName, password, deviceName, response);
  }

  Future<void> _saveCredentials() async {
    final String userName = _emailController.text;
    final String deviceName = _deviceIdController.text;
    await creds.saveDetails(userName, deviceName); // Use the prefixed version
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDialog();
    } else {
      _checkInternetConnectivity();
    }
  }

  Future<void> _checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showInternetConnectivityDialog();
    } else {
      _requestOverlayPermission();
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Location Services Required',
          content: 'The app needs location services to be enabled. Please turn on location services in the next prompt.',
          buttonText1: 'Cancel',
          onPressedButton1: () {
            Navigator.of(context).pop();
          },
          buttonText2: 'Proceed',
          onPressedButton2: () async {
            await Geolocator.openLocationSettings();
            Navigator.of(context).pop();
            _checkLocationServices();
          },
        );
      },
    );
  }

  void _showInternetConnectivityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
            title: 'Internet Connectivity Required',
            content: 'The app needs an internet connection to function correctly. Please connect to a network or turn on cellular data in the next prompt.',
            buttonText1: 'OK',
            onPressedButton1: () {
              Navigator.of(context).pop();
            }
        );
      },
    );
  }

  void _validateCredentials() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final deviceId = _deviceIdController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final deviceIdRegex = RegExp(r'^[a-z0-9]+$');

    setState(() {
      _emailError = email.isEmpty
          ? 'Please enter your email'
          : !emailRegex.hasMatch(email)
          ? 'Invalid email ID'
          : null;

      _passwordError = password.isEmpty
          ? 'Please enter your password'
          : null;

      _deviceIdError = deviceId.isEmpty
          ? 'Please enter your device ID'
          : !deviceIdRegex.hasMatch(deviceId)
          ? 'Device ID must be lowercase alphanumeric'
          : null;
    });

    if (_emailError == null && _passwordError == null && _deviceIdError == null) {
      _checkLocationServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Modularity.homeBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 20),
                Image.asset(
                  'assets/CMW_logo.jpg',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Field Task Manager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'always remain connected',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                EmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  errorText: _emailError,
                ),
                SizedBox(height: 20),
                PasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  errorText: _passwordError,
                ),
                SizedBox(height: 20),
                DeviceIdField(
                  controller: _deviceIdController,
                  focusNode: _deviceIdFocusNode,
                  errorText: _deviceIdError,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]')),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _validateCredentials,
                      child: Text(
                        'CONNECT',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Modularity.connectButtonColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  Modularity.contact,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
