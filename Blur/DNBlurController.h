//
//  DNBlurController.h
//  Blur
//
//  Created by Andrew Pouliot on 4/5/14.
//  Copyright (c) 2014 Darknoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNBlurController : NSObject

- (int32_t)blurImage:(UIImage *)image factor:(float)k completion:(void(^)(UIImage *, int32_t compare))completion;

@end
