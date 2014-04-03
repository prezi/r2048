//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "NSArray+RTTTiles.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSArray+RTTVectors.h"
#import "RTTPoint.h"
#import "RTTTile.h"
#import "RTTVector.h"

@implementation NSArray (RTTTiles)

- (NSArray *(^)())removeZeroTiles {
    return ^{
        return [[self.rac_sequence filter:^BOOL(RTTTile* tile) {
            return tile.value != 0;
        }] array];;
    };
}

- (NSArray *(^)())mapTileArrayToReduceVectors {
    return ^{
        NSArray* result = [NSArray new];

        short currentX = 0;

        for (NSUInteger i = 0; i < [self count]; i++) {
            RTTTile* tile1 = self[i];
            RTTAssert(tile1.value > 0);

            result = [result arrayByAddingObject:vector(tile1.point, point(currentX, tile1.point.y))];

            if (i < [self count] - 1) {
                RTTTile* tile2 = self[i + 1];
                RTTAssert(tile2.value > 0);
                if (tile1.value == tile2.value) {
                    result = [result arrayByAddingObject:mergevector(tile2.point, point(currentX, tile2.point.y))];
                    i++;
                }
            }
            currentX ++;
        }

        return result.removeZeroVectors();
    };
}

@end
