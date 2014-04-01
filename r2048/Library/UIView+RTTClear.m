//
// Created by Viktor Belenyesi on 30/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "UIView+RTTClear.h"

@implementation UIView (RTTClear)

- (void)clear {
    for (UIView* subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
