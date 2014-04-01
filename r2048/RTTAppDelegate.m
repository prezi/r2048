//
//  RTTAppDelegate.m
//  r2048
//
//  Created by Viktor Belenyesi on 29/03/14.
//  Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTAppDelegate.h"
#import "RTTMainViewController.h"

@implementation RTTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (getenv("RTTUnitTest")) return YES;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [RTTMainViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
