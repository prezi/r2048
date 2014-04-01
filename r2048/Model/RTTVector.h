//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTPoint;

@interface RTTVector : NSObject

@property (nonatomic, readonly) RTTPoint* from;
@property (nonatomic, readonly) RTTPoint* to;
@property (nonatomic, readonly) BOOL isMerge;

RTTVector* vector(const RTTPoint* from, const RTTPoint* to);
RTTVector* mergevector(const RTTPoint* from, const RTTPoint* to);
- (RTTVector*(^)())rotateRight;
- (BOOL)isZeroVector;

@end
