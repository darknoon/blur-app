//
//  DNAppDelegate.m
//  Blur
//
//  Created by Andrew Pouliot on 4/5/14.
//  Copyright (c) 2014 Darknoon. All rights reserved.
//

#import "DNAppDelegate.h"

#import "DNBlurViewController.h"
#import "DNBlurController.h"

@implementation DNAppDelegate {
	DNBlurController *_blur;
	UIImageView *_iv;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIViewController *vc = [[DNBlurViewController alloc] init];
	
	_iv = [[UIImageView alloc] init];
	_iv.frame = vc.view.bounds;
	_iv.image = [UIImage imageNamed:@"Hex"];
	_iv.contentMode = UIViewContentModeScaleAspectFill;
	_iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[vc.view addSubview:_iv];
	
	UISlider *slider = [[UISlider alloc] initWithFrame:(CGRect){50, 400, 320-100, 30}];
	slider.value = 0.5;
	[slider addTarget:self action:@selector(amountChanged:) forControlEvents:UIControlEventValueChanged];
	[vc.view addSubview:slider];
	

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
	
	vc.view.backgroundColor = [UIColor greenColor];
	
	_blur = [[DNBlurController alloc] init];
	[self _enqueueWithFactor:0.5];
	
    return YES;
}

- (void)_enqueueWithFactor:(CGFloat)f
{
	[_blur blurImage:[UIImage imageNamed:@"Hex"] factor:f completion:^(UIImage *blur) {
		if (blur) {
			_iv.image = blur;
		}
	}];

}

- (void)amountChanged:(UISlider *)sender
{
	[self _enqueueWithFactor:sender.value];
}

@end
