//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@interface UIColor (RTTFromHex)

+ (UIColor *)fromHex:(NSUInteger)rgbValue;
+ (UIColor *)fromHex:(NSUInteger)rgbValue alpha:(float)alpha;

@end
