//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTReduceCommand.h"

@class RTTPoint;

@interface RTTVector : NSObject<RTTReduceCommand>

@property (nonatomic, readonly) RTTPoint* from;
@property (nonatomic, readonly) RTTPoint* to;
@property (nonatomic, readonly) BOOL isMerge;

RTTVector* vector(RTTPoint* from, RTTPoint* to);
RTTVector* mergevector(RTTPoint* from, RTTPoint* to);
- (RTTVector*(^)())rotateRight;
- (BOOL)isZeroVector;

@end
