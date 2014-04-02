//
// Created by Viktor Belenyesi on 29/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import "RTTMatrixViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSArray+RTTVectors.h"
#import "RTTMatrix.h"
#import "RTTPoint.h"
#import "RTTTile.h"
#import "RTTTileView.h"
#import "RTTVector.h"
#import "UIColor+RTTFromHex.h"
#import "UIView+RTTClear.h"

@interface RTTMatrixViewController ()
@property (nonatomic) RTTMatrix* matrix;
@property (nonatomic, readwrite) int score;
@end

static CGRect (^mapPointToFrame)(RTTPoint*) = ^CGRect (RTTPoint* point) {
    return CGRectMake(kTileGap + kTileDelta * point.x,
                      kTileGap + kTileDelta * point.y,
                      kTileSize,
                      kTileSize);
};


@implementation RTTMatrixViewController

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kTableSize, kTableSize)];
    self.view.backgroundColor = [UIColor fromHex:0xbbada0];
    self.view.layer.cornerRadius = 6.0f;

    UIView *gameView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:gameView];

    // Game Over view
    UIView* gameOverView = [[UIView alloc] initWithFrame:self.view.bounds];
    gameOverView.backgroundColor = [UIColor fromHex:0xeee4da alpha:0.7f];

    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 60.0f, gameOverView.bounds.size.width, 80.0f)];
    titleLabel.textColor = [UIColor fromHex:0x776e65];
    titleLabel.font = [UIFont boldSystemFontOfSize:40.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    titleLabel.text = @"Game Over!";
    [gameOverView addSubview:titleLabel];

    UIButton* retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [retryButton setTitle:@"Try again" forState:UIControlStateNormal];
    [retryButton setTitleColor:[UIColor fromHex:0xf9f6f2] forState:UIControlStateNormal];
    retryButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    retryButton.backgroundColor = [UIColor fromHex:0x8f7a66];
    retryButton.frame = CGRectMake((CGRectGetWidth(gameOverView.bounds) - kButtonWidth) * 0.5f,
                                   160.0f,
                                   kButtonWidth,
                                   kButtonHeight);
    retryButton.layer.cornerRadius = 3.0f;
    retryButton.showsTouchWhenHighlighted = YES;
    [gameOverView addSubview:retryButton];
    [self.view addSubview:gameOverView];

    // helper functions
    RACSequence* (^mapTileViewsForPoint)(RTTPoint*) = ^RACSequence* (RTTPoint* point) {
        return [gameView.subviews.rac_sequence filter:^BOOL(RTTTileView* tileView) {
            return [tileView.point isEqual:point];
        }];
    };

    id(^firstTileViewsForPoint)(RTTPoint*) = ^id (RTTPoint* point) {
        return [mapTileViewsForPoint(point) head];
    };

    RTTTileView*(^mapTileToTileView)(RTTTile*) = ^RTTTileView*(RTTTile* tile) {
        RTTTileView* tileView = [[RTTTileView alloc] initWithFrame:mapPointToFrame(tile.point) tile:tile];
        return tileView;
    };

    // draw background tiles
    [[[emptyMatrix().getTiles().rac_sequence map:mapTileToTileView].signal
        deliverOn:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(RTTTileView* tileView) {
            [self.view insertSubview:tileView belowSubview:gameView];
        }];

    // game logic
    _resetGameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal*(id input) {
        [gameView clear];

        gameOverView.alpha = 0.0f;
        self.matrix = emptyMatrix();
        self.score = 0;

        return [RACSignal empty];
    }];

    retryButton.rac_command = _resetGameCommand;

    // on reset button tap add two random tiles to the signal stream
    RACSignal* createInitialTilesSignal = [[[self.resetGameCommand executing]
        filter:^BOOL(NSNumber* executing) {
            return [executing boolValue];
        }]
        map:^id(id value) {
            RTTTile* firstRandomTile = self.matrix.getNewRandomTile();
            RTTTile* secondRandomTile = self.matrix.applyReduceVectors(@[firstRandomTile]).getNewRandomTile();
            return @[firstRandomTile, secondRandomTile];
        }];

    // add gesture recognizers
    NSArray* signalArray = [NSArray new];
    for (short i = 0; i < 4; i++) {
        UISwipeGestureRecognizerDirection direction = (UISwipeGestureRecognizerDirection)(1 << i);

        UISwipeGestureRecognizer* gestureRecognizer = [UISwipeGestureRecognizer new];
        gestureRecognizer.direction = direction;
        [self.view addGestureRecognizer:gestureRecognizer];

        RACSignal* gestureRecognizerSignal = [gestureRecognizer.rac_gestureSignal mapReplace:@(direction)];
        signalArray = [signalArray arrayByAddingObject:gestureRecognizerSignal];
    }

    // merge 4 directional gesturerecognizers into one stream
    RACSignal* swipeSignal = [RACSignal merge:signalArray];

    RACSignal* vectorSignal = [[swipeSignal
        map:^id(NSNumber* direction) {
            // map the directions to animation vectors
            return self.matrix.mapDirectionToReduceVectors(direction);
        }]
        filter:^BOOL(NSArray* vectors) {
            return [vectors count] > 0;
        }];

    // after every swipe add one random tile the signal stream
    vectorSignal = [vectorSignal
        map:^id(NSArray* vectors) {
            RTTTile* tile = self.matrix.applyReduceVectors(vectors).getNewRandomTile();
            return [vectors arrayByAddingObject:tile];
        }];

    // do the animations either if event arrives from swipe or from reset button
    vectorSignal = [RACSignal merge:@[vectorSignal, createInitialTilesSignal]];

    // animations as side effects
    vectorSignal = [vectorSignal doNext:^(NSArray* vectors) {
        NSLog(@"vectors: %@", vectors);
        NSArray* moves = vectors.filterMoves();
        NSArray* creates = vectors.filterCreates();
        NSArray* merges = moves.filterMergePoints();

        RTTMatrix* reducedMatrix = self.matrix.applyReduceVectors(vectors);

        // moves
        NSArray* tileViewsToMove = [[[moves.rac_sequence
            map:^id(RTTVector* vector) {
                return vector.from;
            }]
            map:firstTileViewsForPoint]
            array];

        // remove old tileviewss
        for (RTTTileView* tileView in tileViewsToMove) {
            [tileView removeFromSuperview];
        }

        // create replace tiles, copy frame and change point, because tileviews are immutables
        tileViewsToMove = [[[moves.rac_sequence
            zipWith:tileViewsToMove.rac_sequence]
            map:^id(RACTuple* tuple) {
                RTTVector* vector = tuple.first;
                RTTTileView* tileView = tuple.second;

                RTTTileView* replaceTileView = mapTileToTileView(tile(vector.to, tileView.value));
                replaceTileView.frame = tileView.frame;
                return replaceTileView;
            }]
            array];

        for (RTTTileView* tileView in tileViewsToMove) {
            [gameView insertSubview:tileView atIndex:0];
        }

        // collect tiles to remove after merge
        NSArray* tileViewsToDiscard = [[[merges.rac_sequence
            map:mapTileViewsForPoint]
            flatten]
            array];

        // get merged tiles
        NSArray* tileViewsToMerge = [[[merges.rac_sequence
            map:^id(RTTPoint* point) {
                return tile(point, reducedMatrix.valueAt(point));
            }]
            map:mapTileToTileView]
            array];

        // get to creat tileviews
        NSArray* tileViewsToCreate = [[creates.rac_sequence
            map:mapTileToTileView]
            array];

        // set score
        self.score += [[[merges.rac_sequence
            map:^id(RTTPoint* point) {
                return @(reducedMatrix.valueAt(point));
            }]
            foldLeftWithStart:@0
            reduce:^id(NSNumber* accumulator, NSNumber* next) {
                return @(accumulator.intValue + next.intValue);
            }]
            intValue];

        [self animateTileViewsToCreate:tileViewsToCreate
                                  move:tileViewsToMove
                                 merge:tileViewsToMerge
                               discard:tileViewsToDiscard
                                inView:gameView];
    }];

    RACSignal* matrixChangedSignal = RACObserve(self, matrix);

    RACSignal* gameOverChangedSignal = [[matrixChangedSignal
        filter:^BOOL(RTTMatrix* matrix) {
            return matrix != nil;
        }]
        map:^id(RTTMatrix* matrix) {
            return @(matrix.isOver());
        }];

    RACSignal* gameIsOverSignal = [[gameOverChangedSignal
        filter:^BOOL(NSNumber* gameOver) {
            return [gameOver boolValue];
        }]
        delay:kSlideAnimDuration + kScaleAnimDuration];

    // apply the changes to the matrix
    RACSignal* reduceMatrixSignal = [vectorSignal
        map:^id(NSArray* vectors) {
            return self.matrix.applyReduceVectors(vectors);
        }];

    // use signals

    // assign the new matrix to itself
    RAC(self, matrix) = reduceMatrixSignal;

    [gameIsOverSignal
        subscribeNext:^(id x) {
            [UIView animateWithDuration:kSlideAnimDuration * 4.0f animations:^{
                gameOverView.alpha = 1.0f;
            }];
        }];

    // log
    [matrixChangedSignal
        subscribeNext:^(RTTMatrix* x) {
            NSLog(@"matrix: %@", x);
        }];

    // starts
    [self.resetGameCommand execute:nil];
}

- (void)animateTileViewsToCreate:(NSArray*)tileViewsToCreate
                            move:(NSArray*)tileViewsToMove
                           merge:(NSArray*)tileViewsToMerge
                         discard:(NSArray*)tileViewsToDiscard
                          inView:(UIView*)container {
    // create animations
    for (RTTTileView* tileView in tileViewsToCreate) {
        tileView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        tileView.alpha = 0.0f;
        [container addSubview:tileView];
    }
    [UIView animateWithDuration:kScaleAnimDuration
                          delay:kSlideAnimDuration
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         for (RTTTileView* tileView in tileViewsToCreate) {
                             tileView.alpha = 1.0f;
                             tileView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
                     }
                     completion:nil];

    // move animation
    [UIView animateWithDuration:kSlideAnimDuration
                      delay:0.0f
                    options:UIViewAnimationOptionCurveEaseIn
                 animations:^{
        for (RTTTileView* tile in tileViewsToMove) {
            tile.frame = mapPointToFrame(tile.point);
        }
    } completion:^(BOOL finished) {

        // add merge tiles now
        for (RTTTileView* tileView in tileViewsToMerge) {
            tileView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            [container addSubview:tileView];
        }

        // merge animations
        [UIView animateKeyframesWithDuration:kScaleAnimDuration
                                       delay:0.0f
                                     options:UIViewKeyframeAnimationOptionCalculationModeCubic
                                  animations:^{
            for (RTTTileView* tileView in tileViewsToMerge) {
                [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.5f animations:^{
                    tileView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                }];
                [UIView addKeyframeWithRelativeStartTime:0.5f relativeDuration:0.5f animations:^{
                    tileView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                }];
            }
        } completion:^(BOOL finished2) {
            // remove the merge sources
            for (RTTTileView* tileView in tileViewsToDiscard) {
                [tileView removeFromSuperview];
            }
        }];

    }];
}

@end
