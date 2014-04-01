//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTPoint;

@interface RTTTile : NSObject

@property (nonatomic, readonly) RTTPoint* point;
@property (nonatomic, readonly) int value;

RTTTile* tile(const RTTPoint* point, int value);
- (RTTTile* (^)())invert;
- (RTTPoint* (^)())toPoint;

@end