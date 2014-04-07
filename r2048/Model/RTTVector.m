//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTMatrix.h"
#import "RTTPoint.h"
#import "RTTVector.h"

@implementation RTTVector

RTTVector* _vector(RTTPoint* from, RTTPoint* to, BOOL isMerge) {
    return [RTTVector vectorWithFrom:from to:to isMerge:isMerge];
}

RTTVector* vector(RTTPoint* from, RTTPoint* to) {
    return _vector(from, to, NO);
}

RTTVector* mergevector(RTTPoint* from, RTTPoint* to) {
    return _vector(from, to, YES);
}

+ (instancetype)vectorWithFrom:(RTTPoint*)from to:(RTTPoint*)to isMerge:(BOOL)isMerge {
    return [[self alloc] initWithFrom:from to:to isMerge:isMerge];
}

- (instancetype)initWithFrom:(RTTPoint*)from to:(RTTPoint*)to isMerge:(BOOL)isMerge {
    self = [super init];
    if (self) {
        _from = from;
        _to = to;
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

#pragma mark - ReduceCommand protocol

- (RTTMatrix*(^)(RTTMatrix*))apply {
    return ^(RTTMatrix* sourceMatrix) {
        return sourceMatrix.subtractValue(self.from, sourceMatrix.valueAt(self.from)).addValue(self.to, sourceMatrix.valueAt(self.from));
    };
}

#pragma mark - Copy, equal

- (BOOL)isEqual:(id)object {
    RTTVector* otherVector = (RTTVector*)object;
    if (self == otherVector) return YES;
    if (otherVector == nil) return NO;
    
    return [otherVector.from isEqual:self.from] && [otherVector.to isEqual:self.to];
}

- (NSUInteger)hash {
    return self.from.hash + self.to.hash * kMatrixSize + (self.isMerge ? 1 : 0) * kMatrixSize * kMatrixSize;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ -> %@>[%@]", self.from, self.to, self.isMerge ? @"YES" : @"NO"];
}

@end
