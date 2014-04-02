//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTTile.h"
#import "RTTPoint.h"

@implementation RTTTile

RTTTile* tile(const RTTPoint* point, int value) {
    return [RTTTile tileWithPoint:point value:value];
}

+ (instancetype)tileWithPoint:(const RTTPoint*)point value:(int)value {
    return [[self alloc] initWithPoint:point value:value];
}

- (instancetype)initWithPoint:(const RTTPoint*)point value:(int)value {
    self = [super init];
    if (self) {
        _point = (RTTPoint* )point;
        _value = value;
    }

    return self;
}

- (RTTTile* (^)())flip {
    return ^{
        return tile(self.point, self.value == 0 ? 2 : 0);
    };
}

- (RTTPoint* (^)())toPoint {
    return ^{
        return self.point;
    };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ = %d", self.point, self.value];
}

@end
