//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTMainViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RTTMatrixViewController.h"
#import "RTTScoreView.h"
#import "UIColor+RTTFromHex.h"

static NSString *const kBestScoreKey = @"RTTBestScore";

@interface RTTMainViewController ()
@property (nonatomic) int bestScore;
@end

@implementation RTTMainViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor fromHex:0xfaf8ef];

    RTTMatrixViewController* matrixViewController = [RTTMatrixViewController new];
    matrixViewController.view.center = CGPointMake(self.view.center.x, self.view.center.y + 60.0f);
    [self.view addSubview:matrixViewController.view];

    RTTAssert(matrixViewController.resetGameCommand);

    float buttonY = CGRectGetMinY(matrixViewController.view.frame) - kButtonHeight - 20.0f;

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.view.bounds.size.width, 80.0f)];
    titleLabel.textColor = [UIColor fromHex:0x776e65];
    titleLabel.font = [UIFont boldSystemFontOfSize:40.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    titleLabel.text = @"Reactive2048";
    [self.view addSubview:titleLabel];

    RTTScoreView* scoreView = [[RTTScoreView alloc] initWithFrame:CGRectMake(CGRectGetMinX(matrixViewController.view.frame),
                                                                             buttonY,
                                                                             kButtonWidth,
                                                                             kButtonHeight)
                                                         andTitle:@"SCORE"];
    scoreView.animateChange = YES;
    [self.view addSubview:scoreView];

    RTTScoreView* bestView = [[RTTScoreView alloc] initWithFrame:CGRectMake(CGRectGetMidX(matrixViewController.view.frame) - kButtonWidth * 0.5f,
                                                                            buttonY,
                                                                            kButtonWidth,
                                                                            kButtonHeight)
                                                        andTitle:@"BEST"];
    [self.view addSubview:bestView];

    UIButton* resetGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetGameButton setTitle:@"New Game" forState:UIControlStateNormal];
    [resetGameButton setTitleColor:[UIColor fromHex:0xf9f6f2] forState:UIControlStateNormal];
    resetGameButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    resetGameButton.backgroundColor = [UIColor fromHex:0x8f7a66];
    resetGameButton.frame = CGRectMake(CGRectGetMaxX(matrixViewController.view.frame) - kButtonWidth,
                                       buttonY,
                                       kButtonWidth,
                                       kButtonHeight);
    resetGameButton.layer.cornerRadius = 3.0f;
    resetGameButton.rac_command = matrixViewController.resetGameCommand;
    resetGameButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:resetGameButton];

    // Scores

    RACSignal* scoreSignal = RACObserve(matrixViewController, score);
    RACSignal* bestScoreSignal = RACObserve(self, bestScore);

    RAC(self, bestScore) = [[[RACSignal
            combineLatest:@[scoreSignal, bestScoreSignal]
                   reduce:(id (^)()) ^NSNumber*(NSNumber* score, NSNumber* best) {
                                          return @(MAX([score intValue], [best intValue]));
                                      }]
        distinctUntilChanged]
        startWith:@([self savedBestScore])];

    [bestScoreSignal subscribeNext:^(NSNumber* bestScore) {
        [self saveBestScore:[bestScore intValue]];
    }];

    // UI bindings
    RAC(scoreView, score) = scoreSignal;
    RAC(bestView, score) = bestScoreSignal;
}

- (void)saveBestScore:(int)score {
    [[NSUserDefaults standardUserDefaults] setInteger:score forKey:kBestScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)savedBestScore {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kBestScoreKey];
}


@end
