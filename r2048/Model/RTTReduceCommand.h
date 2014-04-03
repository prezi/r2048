//
// Created by Belényesi Viktor on 03/04/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTMatrix;

@protocol RTTReduceCommand <NSObject>
@required
- (RTTMatrix*(^)(RTTMatrix*))apply;
@end
