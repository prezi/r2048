//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTVector.h"
#import "RTTPoint.h"

@implementation RTTVector

RTTVector* vector(RTTPoint* from, RTTPoint* to) {
    return _vector(from, to, NO);
}

RTTVector* mergevector(RTTPoint* from, RTTPoint* to) {
    return _vector(from, to, YES);
}

RTTVector* _vector(RTTPoint* from, RTTPoint* to, BOOL isMerge) {
    return [RTTVector vectorWithFrom:from to:to isMerge:isMerge];
}

+ (instancetype)vectorWithFrom:(RTTPoint*)from to:(RTTPoint*)to isMerge:(BOOL)isMerge {
    return [[self alloc] initWithFrom:from to:to isMerge:isMerge];
}

- (instancetype)initWithFrom:(RTTPoint*)from to:(RTTPoint*)to isMerge:(BOOL)isMerge {
    self = [super init];
    if (self) {
        _from = (RTTPoint*)from;
        _to = (RTTPoint*)to;
        _isMerge = isMerge;
    }

    return self;
}

- (BOOL)isZeroVector {
    return (self.from.x == self.to.x) && (self.from.y == self.to.y);
}

- (RTTVector*(^)())rotateRight {
    return ^{
        return _vector(self.from.reverse().invert(), self.to.reverse().invert(), self.isMerge);
    };
}

- (BOOL)isEqual:(id)object {
    RTTVector* otherVector = (RTTVector*)object;
    return [otherVector.from isEqual:self.from] && [otherVector.to isEqual:self.to];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ -> %@>[%@]", self.from, self.to, self.isMerge ? @"YES" : @"NO"];
}

@end
