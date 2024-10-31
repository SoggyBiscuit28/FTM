import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:login_page/modularity.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;

  EmailField({required this.controller, required this.focusNode, this.errorText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Email ID',
        hintText: 'Enter provided Email ID',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        errorText: errorText,
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;

  PasswordField({required this.controller, required this.focusNode, this.errorText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter password',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        errorText: errorText,
      ),
      obscureText: true,
      onChanged: (text) {
        // Handle onChange if needed
      },
    );
  }
}

class DeviceIdField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  DeviceIdField({required this.controller, required this.focusNode, this.errorText, this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Device ID',
        hintText: 'Enter provided device ID',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Modularity.themeColor),
        ),
        errorText: errorText,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9]')),
      ],
      onChanged: (text) {
        // Handle onChange if needed
      },
    );
  }
}
