//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "NSArray+RTTVectors.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RTTTile.h"
#import "RTTVector.h"

@implementation NSArray (RTTVectors)

- (NSArray *(^)())rotateRight {
    return ^{
        return[[self.rac_sequence map:^id(RTTVector* vector) {
            return vector.rotateRight();
        }] array];
    };
}

- (NSArray *(^)())removeZeroVectors {
    return ^{
        return [[self.rac_sequence filter:^BOOL(RTTVector* v) {
            return ![v isZeroVector];
        }] array];
    };
}

- (NSArray *(^)())filterMergePoints {
    return ^{
        NSArray* mergePoints = [[[self.rac_sequence filter:^BOOL(id v) {
            return [v isMemberOfClass:[RTTVector class]] && [v isMerge];
        }] map:^id(RTTVector* v) {
            return v.to;
        }] array];
        mergePoints = [mergePoints sortedArrayUsingSelector:@selector(compare:)];
        return mergePoints;
    };
}

- (NSArray *(^)())filterCreates {
    return ^{
        return [[self.rac_sequence filter:^BOOL(id v) {
            return [v isMemberOfClass:[RTTTile class]];
        }] array];
    };
}

- (NSArray *(^)())filterMoves {
    return ^{
        return [[self.rac_sequence filter:^BOOL(id v) {
            return [v isMemberOfClass:[RTTVector class]];
        }] array];
    };
}

@end
