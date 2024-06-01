import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPopup {
  static Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permesso Richiesto'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Questa app ha bisogno del permesso per accedere ai file audio.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Concedi'),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.storage.request();
              },
            ),
            TextButton(
              child: const Text('Nega'),
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
