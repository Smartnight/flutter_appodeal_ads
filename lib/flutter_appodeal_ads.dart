import 'dart:async';

import 'package:flutter/services.dart';

class FlutterAppodealAds {

  bool shouldCallListener;

  final MethodChannel _channel;

  /// Called when the status of the video ad changes.
  RewardedVideoAdListener videoListener;

  static const Map<String, RewardedVideoAppodealAdEvent> _methodToRewardedVideoAdEvent =
      const <String, RewardedVideoAppodealAdEvent>{
    'onRewardedVideoLoaded': RewardedVideoAppodealAdEvent.loaded,
    'onRewardedVideoFailedToLoad': RewardedVideoAppodealAdEvent.failedToLoad,
    'onRewardedVideoPresent': RewardedVideoAppodealAdEvent.present,
    'onRewardedVideoWillDismiss': RewardedVideoAppodealAdEvent.willDismiss,
    'onRewardedVideoFinished': RewardedVideoAppodealAdEvent.finish,
  };

  static final FlutterAppodealAds _instance = new FlutterAppodealAds.private(
    const MethodChannel('flutter_appodeal_ads'),
  );

  FlutterAppodealAds.private(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethod);
  }

  static FlutterAppodealAds get instance => _instance;

  Future initialize(
    String appKey,
    List<AppodealAdType> types,
    bool consent,
  ) async {
    shouldCallListener = false;
    List<int> itypes = new List<int>();
    for (final type in types) {
      itypes.add(type.index);
    }
    _channel.invokeMethod('initialize', <String, dynamic>{
      'appKey': appKey,
      'types': itypes,
      'consent': consent,
    });
  }

  /*
    Shows an Interstitial in the root view controller or main activity
   */
  Future showInterstitial() async {
    shouldCallListener = false;
    _channel.invokeMethod('showInterstitial');
  }

  /*
    Shows an Rewarded Video in the root view controller or main activity
   */
  Future showRewardedVideo() async {
    shouldCallListener = true;
    _channel.invokeMethod('showRewardedVideo');
  }

  Future<bool> isLoaded(AppodealAdType type) async {
    shouldCallListener = false;
    final bool result = await _channel
        .invokeMethod('isLoaded', <String, dynamic>{'type': type.index});
    return result;
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    final Map<dynamic, dynamic> argumentsMap = call.arguments;
    final RewardedVideoAppodealAdEvent rewardedEvent =
        _methodToRewardedVideoAdEvent[call.method];
    if (rewardedEvent != null && shouldCallListener) {
      if (this.videoListener != null) {
        if (rewardedEvent == RewardedVideoAppodealAdEvent.finish && argumentsMap != null) {
          this.videoListener(rewardedEvent,
              rewardType: argumentsMap['rewardType'],
              rewardAmount: argumentsMap['rewardAmount']);
        } else {
          this.videoListener(rewardedEvent);
        }
      }
    }

    return new Future<Null>(null);
  }

  /*static const MethodChannel _channel =
      const MethodChannel('flutter_appodeal_ads');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }*/
}

enum AppodealAdType {
  AppodealAdTypeInterstitial,
  AppodealAdTypeSkippableVideo,
  AppodealAdTypeBanner,
  AppodealAdTypeNativeAd,
  AppodealAdTypeRewardedVideo,
  AppodealAdTypeMREC,
  AppodealAdTypeNonSkippableVideo,
}

enum RewardedVideoAppodealAdEvent {
  loaded,
  failedToLoad,
  present,
  willDismiss,
  finish,
}

typedef void RewardedVideoAdListener(RewardedVideoAppodealAdEvent event,
    {String rewardType, int rewardAmount});
