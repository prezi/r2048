//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTTileView.h"

#import "RTTPoint.h"
#import "RTTTile.h"
#import "UIColor+RTTFromHex.h"

static NSDictionary* bgColorDic;
static NSDictionary* fgColorDic;

@implementation RTTTileView

+ (void)initialize {
    if (self == [RTTTileView class]) {
        bgColorDic = @{
                @2 : @0xeee4da,
                @4 : @0xede0c8,
                @8 : @0xf2b179,
                @16 : @0xf59563,
                @32 : @0xf67c5f,
                @64 : @0xf65e3b,
                @128 : @0xedcf72,
                @256 : @0xedcc61,
                @512 : @0xedc850,
                @1024 : @0xedc53f,
                @2048 : @0xedc22e
        };

        fgColorDic = @{
                @2 : @0x776e65,
                @4 : @0x776e65,
                @8 : @0xf9f6f2,
                @16 : @0xf9f6f2,
                @32 : @0xf9f6f2,
                @64 : @0xf9f6f2,
                @128 : @0xf9f6f2,
                @256 : @0xf9f6f2,
                @512 : @0xf9f6f2,
                @1024 : @0xf9f6f2,
                @2048 : @0xf9f6f2
        };
    }
}

- (instancetype)initWithFrame:(CGRect)frame tile:(RTTTile*)tile {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor fromHex:0xeee4da alpha:0.35f];

        if (tile.value != 0) {
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5.0f, 5.0f)];
            label.textColor = [UIColor fromHex:[fgColorDic[@(tile.value)] unsignedIntegerValue]];
            label.font = [UIFont boldSystemFontOfSize:36];
            label.minimumScaleFactor = 0.3f;
            label.adjustsFontSizeToFitWidth = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            label.text = [NSString stringWithFormat:@"%d", tile.value];
            [self addSubview:label];

            self.backgroundColor = [UIColor fromHex:[bgColorDic[@(tile.value)] unsignedIntegerValue]];
        }
        _point = tile.point;
        _value = tile.value;
        self.layer.cornerRadius = 3.0f;
    }
    return self;
}

#pragma mark - Copy, compare, equal

- (NSComparisonResult)compare:(RTTTileView*)otherView {
    return COMPARE(self.value, otherView.value);
}

- (BOOL)isEqual:(id)object {
    RTTTileView* otherTileView = (RTTTileView*)object;
    if (self == otherTileView) return YES;
    if (otherTileView == nil) return NO;
    
    return [self.point isEqual:otherTileView.point] && self.value == otherTileView.value;
}

- (NSUInteger)hash {
    return self.point.hash + kMatrixSize * kMatrixSize * self.value;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ = %d", self.point, self.value];
}

@end
