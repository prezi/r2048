//
// Created by Viktor Belenyesi on 30/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

@interface RTTScoreView : UIView

@property (nonatomic, assign) int points;
@property (nonatomic, assign) BOOL animateChange;

- (instancetype)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

@end
