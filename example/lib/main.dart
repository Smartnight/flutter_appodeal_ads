import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appodeal_ads/flutter_appodeal_ads.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String videoState;
  bool consent = false;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      List<AppodealAdType> types = new List<AppodealAdType>();
      types.add(AppodealAdType.AppodealAdTypeInterstitial);
      types.add(AppodealAdType.AppodealAdTypeRewardedVideo);
      FlutterAppodealAds.instance.videoListener =
          (RewardedVideoAppodealAdEvent event, {String rewardType, int rewardAmount}) {
        print("RewardedVideoAd event $event");
        setState(() {
          videoState = "State $event";
        });
      };
      // You should use here your APP Key from Appodeal
      await FlutterAppodealAds.instance
          .initialize(Platform.isIOS ? 'd7822f5bdac9b64a6df9895e0709b3f487f74e1125d5250a' : 'ANDROIDAPPKEY', types, consent);
    } on PlatformException {}

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Scaffold(
      appBar: new AppBar(
        title: new Text('$videoState'),
      ),
      body: new Padding(
        padding: new EdgeInsets.only(top: 40.0),
        child: new Center(
            child: new Column(children: <Widget>[
          new Container(
              height: 100.0,
              color: Colors.green,
              child: new FlatButton(
                onPressed: () {
                  this.loadRewarded();
                },
                child: new Text('Show Rewarded'),
              )),
          new Container(
              height: 100.0,
              color: Colors.blue,
              child: new FlatButton(
                onPressed: () {
                  this.loadInterstital();
                },
                child: new Text('Show Interstitial'),
              ))
        ])),
      ),
    ));
  }

  void loadInterstital() async {
    bool loaded = await FlutterAppodealAds.instance
        .isLoaded(AppodealAdType.AppodealAdTypeInterstitial);
    if (loaded) {
      FlutterAppodealAds.instance.showInterstitial();
    } else {
      print("No se ha cargado un Interstitial");
    }
  }

  void loadRewarded() async {
    bool loaded = await FlutterAppodealAds.instance
        .isLoaded(AppodealAdType.AppodealAdTypeRewardedVideo);
    
    if (loaded) {
      FlutterAppodealAds.instance.showRewardedVideo();
    } else {
      print("No se ha cargado un Rewarded Video");
    }
  }
}