//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@interface NSArray (RTTTiles)

- (NSArray *(^)())removeZeroTiles;
- (NSArray *(^)())mapTileArrayToReduceVectors;

@end
