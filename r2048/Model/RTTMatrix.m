//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTMatrix.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSArray+RTTTiles.h"
#import "NSArray+RTTVectors.h"
#import "RTTPoint.h"
#import "RTTTile.h"

static NSDictionary* reduceDic;

@interface RTTMatrix ()
@property (nonatomic, readonly) NSDictionary* matrix;
@end

@implementation RTTMatrix

+ (void)initialize {
    if (self == [RTTMatrix class]) {
        reduceDic = @{
                @(UISwipeGestureRecognizerDirectionLeft) : ^(RTTMatrix* matrix) {
                    return matrix.getReduceVectors();
                },
                @(UISwipeGestureRecognizerDirectionRight) : ^(RTTMatrix* matrix) {
                    return matrix.rotateRight().rotateRight().getReduceVectors().rotateRight().rotateRight();
                },
                @(UISwipeGestureRecognizerDirectionUp) : ^(RTTMatrix* matrix) {
                    return matrix.rotateRight().rotateRight().rotateRight().getReduceVectors().rotateRight();
                },
                @(UISwipeGestureRecognizerDirectionDown) : ^(RTTMatrix* matrix) {
                    return matrix.rotateRight().getReduceVectors().rotateRight().rotateRight().rotateRight();
                },
        };
    }
}

+ (instancetype)matrix {
    return [[RTTMatrix alloc] initWithDictionary:[NSDictionary new]];
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
       _matrix = dictionary;
    }
    return self;
}

#pragma mark - Queries

RTTMatrix* emptyMatrix() {
    return [RTTMatrix matrix];
}

- (int(^)(RTTPoint*))valueAt {
    return ^(RTTPoint* p) {
        RTTAssert(p.x < kMatrixSize && p.y < kMatrixSize && p.x >= 0 && p.y >= 0);
        NSNumber* value = self.matrix[p];
        return value ? [value intValue] : 0;
    };
}

- (NSArray*(^)())getReduceVectors {
    return ^{
        return [[[self.getRowArray().rac_sequence map:^id(NSArray* row) {
            return row.removeZeroTiles().mapTileArrayToReduceVectors().rac_sequence;
        }] flatten] array];
    };
}

- (NSArray*(^)())getRowArray {
    return ^{
        NSArray* tiles = self.getTiles();
        NSArray* result = [NSArray new];
        for (short y = 0; y < kMatrixSize; y++) {
            result = [result arrayByAddingObject:[tiles subarrayWithRange:NSMakeRange((NSUInteger)(y * kMatrixSize), kMatrixSize)]];
        }
        return result;
    };
}

- (NSArray*(^)(NSNumber*))mapDirectionToReduceVectors {
    return ^(NSNumber* direction) {
        NSArray*(^reduceMethod)(RTTMatrix*) = reduceDic[direction];
        return reduceMethod(self);
    };
}

- (NSArray*(^)())getEmptyPositions {
    return ^{
        return [[[self.getTiles().rac_sequence filter:^BOOL(RTTTile* tile) {
            return tile.value == 0;
        }] map:^id(RTTTile* tile) {
            return tile.point;
        }] array];
    };
}

- (NSArray*(^)())getTiles {
    return ^{
        NSArray* result = [NSArray new];
        for (short y = 0; y < kMatrixSize; y++) {
            for (short x = 0; x < kMatrixSize; x++) {
                RTTPoint* p = point(x, y);
                result = [result arrayByAddingObject:tile(p, self.valueAt(p))];
            }
        }
        return result;
    };
}

- (BOOL(^)())isOver {
    return ^{
        for (short y = 0; y < kMatrixSize; y++) {
            for (short x = 0; x < kMatrixSize; x++) {
                int valueAtXY = self.valueAt(point(x, y));

                // if there is a zero value
                if (valueAtXY == 0) {
                    return NO;
                }

                // if there is a horizontal pair
                if (x < kMatrixSize - 1 && valueAtXY == self.valueAt(point(x + 1, y))) {
                    return NO;
                }

                // if there is a vertical pair
                if (y < kMatrixSize - 1 && valueAtXY == self.valueAt(point(x, y + 1))) {
                    return NO;
                }
            }
        }

        return YES;
    };
}

- (RTTTile*(^)())getNewRandomTile {
    return ^{
        NSArray* emptyPoints = self.getEmptyPositions();
        NSUInteger index = arc4random_uniform([emptyPoints count]);
        int value = (arc4random() % 100) > 90 ? 4 : 2;
        return tile(emptyPoints[index], value);
    };
}

#pragma mark - Operations

- (RTTMatrix*(^)(RTTPoint*, int))addValue {
    return ^(RTTPoint* p, int value) {
        RTTAssert(p.x < kMatrixSize && p.y < kMatrixSize && p.x >= 0 && p.y >= 0);
        RTTAssert(value % 2 == 0);

        int newValue = value + self.valueAt(p);

        // Check if power of two
        RTTAssert(newValue != 1 && (newValue & (newValue - 1)) == 0);
        NSMutableDictionary* copyDictionary = [self.matrix mutableCopy];
        [copyDictionary setObject:@(newValue) forKey:p];
        RTTMatrix *matrix = [[RTTMatrix alloc] initWithDictionary:[copyDictionary copy]];
        return matrix;
    };
}

- (RTTMatrix*(^)(RTTPoint*, int))subtractValue {
    return ^(RTTPoint* p, int value) {
        return self.addValue(p, -value);
    };
}

- (RTTMatrix*(^)(NSArray*))applyReduceCommands {
    return ^(NSArray* reduceVectors) {
        RTTMatrix*result = self;
        for (NSObject<RTTReduceCommand>* reduceCommand in reduceVectors) {
            result = reduceCommand.apply(result);
        }
        return result;
    };
}

- (RTTMatrix*(^)())transpose {
    return ^{
        RTTMatrix* result = emptyMatrix();
        short n = kMatrixSize;
        for (short x = 0; x < n; x++) {
            for (short y = x; y < n; y++) {
                RTTPoint* p = point(x, y);
                result = result.addValue(p, self.valueAt(p.reverse()));
                if (x != y) {
                    result = result.addValue(p.reverse(), self.valueAt(p));
                }
            }
        }
        return result;
    };
}

- (RTTMatrix*(^)())reverseRowWise {
    return ^{
        RTTMatrix* result = emptyMatrix();
        for (short y = 0; y < kMatrixSize; y++) {
            for (short x = 0; x < kMatrixSize / 2; x++) {
                RTTPoint* p = point(x, y);
                result = result.addValue(p, self.valueAt(p.invert())).addValue(p.invert(), self.valueAt(p));
            }
        }
        return result;
    };
}

- (RTTMatrix*(^)())rotateRight {
    return ^{
        return self.transpose().reverseRowWise();
    };
}

#pragma mark - Copy, equal

- (BOOL)isEqual:(id)object {
    RTTMatrix* otherMatrix = (RTTMatrix*)object;
    if (self == otherMatrix) return YES;
    if (otherMatrix == nil) return NO;
    
    for (short y = 0; y < kMatrixSize; y++) {
        for (short x = 0; x < kMatrixSize; x++) {
            RTTPoint* p = point(x, y);
            if (self.valueAt(p) != otherMatrix.valueAt(p)) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSString*)description {
    NSMutableString* result = [NSMutableString new];
    [result appendString:@"\n"];
    for (short y = 0; y < kMatrixSize; y++) {
        for (short x = 0; x < kMatrixSize; x++) {
            [result appendFormat:@"%d, ", self.valueAt(point(x, y))];
        }
        [result appendString:@"\n"];
    }
    return [result copy];
}

@end
