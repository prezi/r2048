//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//


@class RTTTile;
@class RTTPoint;

@interface RTTTileView : UIView

@property (nonatomic, readonly) RTTPoint* point;
@property (nonatomic, readonly) int value;

- (instancetype)initWithFrame:(CGRect)frame tile:(RTTTile*)tile;

@end
