//
//  AppDelegate.m
//  XMWeex
//
//  Created by apple on 2017/3/13.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//

#import "AppDelegate.h"
#import <WeexSDK/WeexSDK.h>
#import "XMWXWebImage.h"
#import "XMWXScanViewController.h"
@interface AppDelegate ()

@property (nonatomic,strong) WXSDKInstance * instance;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITabBarController * tabarViewController = [[UITabBarController alloc] init];
    
    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    window.rootViewController = tabarViewController;
    
    

    window.backgroundColor = [UIColor whiteColor];
    [window makeKeyAndVisible];

    [WXAppConfiguration setAppGroup:@"application"];
    [WXAppConfiguration setAppName:@"application"];
    [WXAppConfiguration setAppVersion:@"1.0"];
    
    //init sdk enviroment
    [WXSDKEngine initSDKEnvironment];
    [WXSDKEngine registerModule:@"XMWXModule" withClass:NSClassFromString(@"XMWXModule")];
    [WXSDKEngine registerHandler:[XMWXWebImage new] withProtocol:@protocol(WXImgLoaderProtocol)];
    //通过配置这个Component参数来配置程序框架HTML标签名
    [WXSDKEngine registerComponent:@"AppFrame" withClass:NSClassFromString(@"XMWXAPPFrameComponte")];
    
#if TARGET_IPHONE_SIMULATOR//模拟器
    NSString * renderURL = @"http://192.167.0.3:8083/dist/components/Frame/AppFrame.js";
    //    NSString * renderURL = [NSString stringWithFormat:@"%@%@",host,@"AppFrame.weex.js"];
    [self instance:renderURL];
    
#elif TARGET_OS_IPHONE//真机
    XMWXScanViewController * scanVC = [[XMWXScanViewController alloc] init];
    tabarViewController.viewControllers = @[scanVC];
#endif
    
    [WXLog setLogLevel:WXLogLevelError];

    return YES;
}

-(WXSDKInstance *)instance:(NSString *)renderURLString
{
    if (!_instance) {
        _instance = [[WXSDKInstance alloc] init];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//
        [_instance renderWithURL:[NSURL URLWithString:renderURLString]];
        
    }
    return _instance;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
