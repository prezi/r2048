//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@class RTTMatrix;

@interface RTTMatrixViewController : UIViewController

@property (nonatomic, readonly) RACCommand* resetGameCommand;
@property (nonatomic, readonly) int score;

@end
