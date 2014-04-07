//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTReduceCommand.h"

@class RTTPoint;

@interface RTTTile : NSObject<RTTReduceCommand, NSCopying>

@property (nonatomic, readonly) RTTPoint* point;
@property (nonatomic, readonly) int value;

RTTTile* tile(RTTPoint* point, int value);

@end
