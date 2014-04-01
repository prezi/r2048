//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "UIColor+RTTFromHex.h"

@implementation UIColor (RTTFromHex)

+ (UIColor *)fromHex:(NSUInteger)rgbValue {
    return [self fromHex:rgbValue alpha:1.0f];
}

+ (UIColor *)fromHex:(NSUInteger)rgbValue alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(rgbValue & 0xFF)) / 255.0
                           alpha:alpha];
}

@end
