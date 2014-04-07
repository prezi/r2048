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

#pragma mark - ReduceCommand protocol

- (RTTMatrix*(^)(RTTMatrix*))apply {
    return ^(RTTMatrix* sourceMatrix) {
        return sourceMatrix.addValue(self.point, self.value);
    };
}

#pragma mark - Copy, equal

- (BOOL)isEqual:(id)object {
    RTTTile* otherTile = (RTTTile*)object;
    if (self == otherTile) return YES;
    if (otherTile == nil) return NO;
    
    return [self.point isEqual:otherTile.point] && (self.value == otherTile.value);
}

- (NSUInteger)hash {
    return self.point.hash + kMatrixSize * kMatrixSize * kMatrixSize * self.value;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ = %d", self.point, self.value];
}

@end
