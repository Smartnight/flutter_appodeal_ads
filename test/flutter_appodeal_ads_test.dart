import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_appodeal_ads/flutter_appodeal_ads.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_appodeal_ads');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  /*test('getPlatformVersion', () async {
    expect(await FlutterAppodealAds.platformVersion, '42');
  });*/
}
