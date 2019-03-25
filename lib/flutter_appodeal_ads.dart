import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAppodealAds {
  static const MethodChannel _channel =
      const MethodChannel('flutter_appodeal_ads');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
