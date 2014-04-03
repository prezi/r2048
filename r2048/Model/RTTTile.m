//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTMatrix.h"
#import "RTTPoint.h"
#import "RTTTile.h"

@implementation RTTTile

RTTTile* tile(RTTPoint* point, int value) {
    return [RTTTile tileWithPoint:point value:value];
}

+ (instancetype)tileWithPoint:(RTTPoint*)point value:(int)value {
    return [[self alloc] initWithPoint:point value:value];
}

- (instancetype)initWithPoint:(RTTPoint*)point value:(int)value {
    self = [super init];
    if (self) {
        _point = point;
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

#pragma mark - ReduceCommand protocol

- (RTTMatrix*(^)(RTTMatrix*))apply {
    return ^(RTTMatrix* sourceMatrix) {
        return sourceMatrix.addValue(self.point, self.value);
    };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ = %d", self.point, self.value];
}

@end
