//
//  DNBlurController.m
//  Blur
//
//  Created by Andrew Pouliot on 4/5/14.
//  Copyright (c) 2014 Darknoon. All rights reserved.
//

#include <CoreImage/CoreImage.h>

#import <libkern/OSAtomic.h>

#import "DNBlurController.h"

@implementation DNBlurController
{
	int32_t _cancellation;
	dispatch_queue_t _queue;
}

- (id)init;
{
    self = [super init];
    if (!self) return nil;
	
	const char * s = [[[self class] description] cStringUsingEncoding:NSUTF8StringEncoding];
	_queue = dispatch_queue_create(s, DISPATCH_QUEUE_SERIAL);
	
    return self;
}

+ (UIImage *)blurImage:(UIImage *)image factor:(float)k
{
	CIImage *inputImage = [[CIImage alloc] initWithCGImage:image.CGImage];
	
	CIFilter *clamp = [CIFilter filterWithName:@"CIAffineClamp"];
	[clamp setValue:inputImage
			 forKey:kCIInputImageKey];
	[clamp setValue:[NSValue valueWithBytes:&CGAffineTransformIdentity objCType:@encode(CGAffineTransform)]
			 forKey:kCIInputTransformKey];
	
	CIImage *clamped = [clamp valueForKey:kCIOutputImageKey];
	
	CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
	NSAssert(blur, @"Couldn't make a blur filter");
	
	CGFloat kernelSize = MAX(image.size.width, image.size.height) * 0.1 * k;
	
	[blur setValue:clamped
			forKey:kCIInputImageKey];
	[blur setValue:@(kernelSize)
			forKey:kCIInputRadiusKey];
	CIImage *blurred = [blur valueForKey:kCIOutputImageKey];
	

	CGRect imr = (CGRect){CGPointZero, image.size};
	blurred = [blurred imageByCroppingToRect:imr];
	
	UIImage *outimage = [UIImage imageWithCIImage:blurred];

	UIGraphicsBeginImageContextWithOptions(image.size, YES, 1.0);
	[outimage drawAtPoint:CGPointZero];
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	
	return finalImage;
}

- (int32_t)blurImage:(UIImage *)image factor:(float)k completion:(void(^)(UIImage *, int32_t compare))completion
{
	if (!completion) return 0;
	uint32_t expected = OSAtomicIncrement32(&_cancellation);
	dispatch_async(_queue, ^{
		UIImage *retval = nil;
		if (_cancellation == expected) {
			retval = [self.class blurImage:image factor:k];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(retval, expected);
		});
	});
	return expected;
}

@end
