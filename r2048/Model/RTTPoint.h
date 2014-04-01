//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@interface RTTPoint : NSObject

@property (nonatomic, readonly) short x;
@property (nonatomic, readonly) short y;

RTTPoint* point(short x, short y);
- (RTTPoint* (^)())reverse;
- (RTTPoint* (^)())invert;

@end
