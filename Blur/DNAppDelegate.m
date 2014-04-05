//
//  DNAppDelegate.m
//  Blur
//
//  Created by Andrew Pouliot on 4/5/14.
//  Copyright (c) 2014 Darknoon. All rights reserved.
//

#import "DNAppDelegate.h"

#import "DNBlurViewController.h"

@implementation DNAppDelegate {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIViewController *vc = [[DNBlurViewController alloc] init];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = vc;
	self.window.tintColor = [UIColor orangeColor];
    [self.window makeKeyAndVisible];
	
    return YES;
}

@end
