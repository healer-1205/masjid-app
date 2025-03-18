import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Constants {
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('connected');
        }
        return true;
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('not connected');
      }
      return false;
    }
    return false;
  }
}
