import 'package:flutter/material.dart';
import 'modularity.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText1;
  final VoidCallback onPressedButton1;
  final String? buttonText2;
  final VoidCallback? onPressedButton2;

  CustomDialog({
    required this.title,
    required this.content,
    required this.buttonText1,
    required this.onPressedButton1,
    this.buttonText2,
    this.onPressedButton2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40.0), // Adjust horizontal padding
      child: Container(
        width: MediaQuery.of(context).size.width * 2, // Set the desired width
        padding: EdgeInsets.all(16.0),
        color: Color(0xFFf7f7f7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(buttonText1, style: TextStyle(fontSize: 14, color: Modularity.themeColor)),
                  onPressed: onPressedButton1,
                ),
                if (buttonText2 != null && onPressedButton2 != null)
                  TextButton(
                    child: Text(buttonText2!, style: TextStyle(fontSize: 14, color: Modularity.themeColor)),
                    onPressed: onPressedButton2,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
