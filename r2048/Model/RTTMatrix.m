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
#import "RTTVector.h"

static NSDictionary* reduceDic;

@interface RTTMatrix ()
@property (nonatomic, readonly) NSArray* matrix;
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
    NSArray* result = [NSArray new];

    for (short y = 0; y < kMatrixSize; y++) {
        NSArray* row = [NSArray new];
        for (short x = 0; x < kMatrixSize; x++) {
            row = [row arrayByAddingObject:tile(point(x, y), 0)];
        }
        result = [result arrayByAddingObject:row];
    }

    return [[RTTMatrix alloc] initWith2DArray:result];
}

- (instancetype)initWith2DArray:(NSArray*)matrix {
    self = [super init];
    if (self) {
       _matrix = [matrix copy];
    };
    return self;
}

#pragma mark - Queries

RTTMatrix* emptyMatrix() {
    return [RTTMatrix matrix];
}

- (int(^)(RTTPoint*))valueAt {
    return ^(RTTPoint* p) {
        RTTAssert(p.x < kMatrixSize && p.y < kMatrixSize && p.x >= 0 && p.y >= 0);
        RTTTile* tile = self.matrix[p.y][p.x];
        return tile.value;
    };
}

- (BOOL)isEqual:(id)object {
    RTTMatrix* otherMatrix = (RTTMatrix*)object;

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

- (NSArray*(^)())getReduceVectors {
    return ^{
        return [[[self.matrix.rac_sequence map:^id(NSArray* row) {
            return row.removeZeroTiles().mapTileArrayToReduceVectors().rac_sequence;
        }] flatten] array];
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
        return [[[self.matrix.rac_sequence map:^id(NSArray* row) {
            return row.flipTiles().removeZeroTiles().convertTilesToPoints().rac_sequence;
        }] flatten] array];
    };
}

- (NSArray*(^)())getTiles {
    return ^{
        return [[[self.matrix.rac_sequence map:^id(NSArray* row) {
            return row.rac_sequence;
        }] flatten] array];
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
        NSUInteger index = arc4random_uniform(emptyPoints.count);
        int value = (arc4random() % 100) > 90 ? 4 : 2;
        return tile(emptyPoints[index], value);
    };
}

#pragma mark - Operations

- (RTTMatrix*(^)(RTTPoint*, int))addValue {
    return ^(RTTPoint* p, int value) {
        RTTAssert(p.x < kMatrixSize && p.y < kMatrixSize && p.x >= 0 && p.y >= 0);
        RTTAssert(value % 2 == 0);

        NSUInteger y = (NSUInteger) p.y;

        NSMutableArray* mutableCopy = [self.matrix mutableCopy];
        NSMutableArray* mutableRow = [mutableCopy[y] mutableCopy];
        int newValue = value + self.valueAt(p);

        // Check if power of two
        RTTAssert(newValue != 1 && (newValue & (newValue - 1)) == 0);

        mutableRow[(NSUInteger)p.x] = tile(p, newValue);
        mutableCopy[y] = [mutableRow copy];
        return [[RTTMatrix alloc] initWith2DArray:mutableCopy];
    };
}

- (RTTMatrix*(^)(RTTPoint*, int))subtractValue {
    return ^(RTTPoint* p, int value) {
        return self.addValue(p, -value);
    };
}

- (RTTMatrix*(^)(NSArray*))applyReduceVectors {
    return ^(NSArray* reduceVectors) {
        RTTMatrix*result = self;
        for (NSObject* o in reduceVectors) {
            if ([o isMemberOfClass:[RTTVector class]]) {
                RTTVector* v = (RTTVector*)o;
                result = result.subtractValue(v.from, self.valueAt(v.from)).addValue(v.to, self.valueAt(v.from));
            } else if ([o isMemberOfClass:[RTTTile class]]){
                RTTTile* t = (RTTTile*)o;
                result = result.addValue(t.point, t.value);
            }
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

#pragma mark - Debug

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
