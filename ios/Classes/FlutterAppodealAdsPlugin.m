#import "FlutterAppodealAdsPlugin.h"

/*@implementation FlutterAppodealAdsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_appodeal_ads"
            binaryMessenger:[registrar messenger]];
  FlutterAppodealAdsPlugin* instance = [[FlutterAppodealAdsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end*/

@interface FlutterAppodealAdsPlugin(){
    FlutterMethodChannel* channel;
}
@end

@implementation FlutterAppodealAdsPlugin

+ (UIViewController *)rootViewController {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_appodeal_ads"
                                     binaryMessenger:[registrar messenger]];
    FlutterAppodealAdsPlugin* instance = [[FlutterAppodealAdsPlugin alloc] init];
    [instance setChannel:channel];
    [Appodeal setRewardedVideoDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void) setChannel:(FlutterMethodChannel*) chan{
    channel = chan;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
        NSString* appKey = call.arguments[@"appKey"];
        NSArray* types = call.arguments[@"types"];
        //BOOL consent
       // NSNumber numberWithBool consent
        //= call.arguments[@"consent"];
        AppodealAdType type = types.count > 0 ? [self typeFromParameter:types.firstObject] : AppodealAdTypeInterstitial;
        int i = 1;
        while (i < types.count) {
            type = type | [self typeFromParameter:types[i]];
            i++;
        }
        [Appodeal initializeWithApiKey:appKey types:type hasConsent:YES];
        result([NSNumber numberWithBool:YES]);
    }else if ([@"showInterstitial" isEqualToString:call.method]) {
        [Appodeal showAd:AppodealShowStyleInterstitial rootViewController:[FlutterAppodealAdsPlugin rootViewController]];
        result([NSNumber numberWithBool:YES]);
    }else if ([@"showRewardedVideo" isEqualToString:call.method]) {
        [Appodeal showAd:AppodealShowStyleRewardedVideo rootViewController:[FlutterAppodealAdsPlugin rootViewController]];
        result([NSNumber numberWithBool:YES]);
    }else if ([@"isLoaded" isEqualToString:call.method]) {
        NSNumber *type = call.arguments[@"type"];
        result([NSNumber numberWithBool:[Appodeal isReadyForShowWithStyle:[self showStyleFromParameter:type]]]);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (AppodealAdType) typeFromParameter:(NSNumber*) parameter{
    switch ([parameter intValue]) {
        case 0:
            return AppodealAdTypeInterstitial;
        case 4:
            return AppodealAdTypeRewardedVideo;
            
        default:
            break;
    }
    return AppodealAdTypeInterstitial;
}

- (AppodealShowStyle) showStyleFromParameter:(NSNumber*) parameter{
    switch ([parameter intValue]) {
        case 0:
            return AppodealShowStyleInterstitial;
        case 4:
            return AppodealShowStyleRewardedVideo;
            
        default:
            break;
    }
    return AppodealShowStyleInterstitial;
}

#pragma mark - RewardedVideo Delegate

- (void)rewardedVideoDidLoadAd {
    [channel invokeMethod:@"onRewardedVideoLoaded" arguments:nil];
}

- (void)rewardedVideoDidFailToLoadAd {
    [channel invokeMethod:@"onRewardedVideoFailedToLoad" arguments:nil];
}

- (void)rewardedVideoDidPresent {
    [channel invokeMethod:@"onRewardedVideoPresent" arguments:nil];
}

- (void)rewardedVideoWillDismiss {
    [channel invokeMethod:@"onRewardedVideoWillDismiss" arguments:nil];
}

- (void)rewardedVideoDidFinish:(NSUInteger)rewardAmount name:(NSString *)rewardName {
    NSDictionary *params = rewardName != nil ? @{
                                                 @"rewardAmount" : @(rewardAmount),
                                                 @"rewardType" : rewardName
                                                 }: nil;
    [channel invokeMethod:@"onRewardedVideoFinished" arguments: params];
}

@end
