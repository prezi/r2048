//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTPoint;
@class RTTTile;

@interface RTTMatrix : NSObject

RTTMatrix* emptyMatrix();

- (int(^)(const RTTPoint*))valueAt;

- (NSArray*(^)( NSNumber*))mapDirectionToReduceVectors;
- (NSArray*(^)())getEmptyPositions;
- (NSArray*(^)())getTiles;
- (BOOL(^)())isOver;
- (RTTTile*(^)())getNewRandomTile;

- (RTTMatrix*(^)(const RTTPoint*, int))addValue;
- (RTTMatrix*(^)(const RTTPoint*, int))subtractValue;
- (RTTMatrix*(^)(NSArray*))applyReduceVectors;
- (RTTMatrix*(^)())rotateRight;
- (RTTMatrix*(^)())transpose;
- (RTTMatrix*(^)())reverseRowWise;

@end
