//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTPoint;
@class RTTTile;

@interface RTTMatrix : NSObject

RTTMatrix* emptyMatrix();

- (int(^)(RTTPoint*))valueAt;

- (NSArray*(^)( NSNumber*))mapDirectionToReduceVectors;
- (NSArray*(^)())getEmptyPositions;
- (NSArray*(^)())getTiles;
- (BOOL(^)())isOver;
- (RTTTile*(^)())getNewRandomTile;

- (RTTMatrix*(^)(RTTPoint*, int))addValue;
- (RTTMatrix*(^)(RTTPoint*, int))subtractValue;
- (RTTMatrix*(^)(NSArray*))applyReduceCommands;
- (RTTMatrix*(^)())rotateRight;
- (RTTMatrix*(^)())transpose;
- (RTTMatrix*(^)())reverseRowWise;

@end
