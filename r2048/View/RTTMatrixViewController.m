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

@implementation RACSignal (RTT)

- (RACSignal*)named:(NSString*)aName {
    self.name = aName;
    return self;
}

@end


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
        self.matrix = nil;
//        self.matrix = emptyMatrix();
        self.score = 0;

        RACSignal* resetSignal = [RACSignal empty];
        resetSignal.name = @"reset";
        return resetSignal;
    }];

    retryButton.rac_command = _resetGameCommand;

    RACSignal* matrixSignal = [[[RACObserve(self, matrix)
        ignore:nil] named:@"matrix"] logNext];
    
    // on reset button tap add two random tiles to the signal stream
//    [self.resetGameCommand.executionSignals
//        subscribeNext:^(id x) {
//            RTTTile* firstRandomTile = self.matrix.getNewRandomTile();
//            RTTTile* secondRandomTile = self.matrix.applyReduceCommands(@[firstRandomTile]).getNewRandomTile();
//            self.matrix = self.matrix.applyReduceCommands(@[firstRandomTile, secondRandomTile]);
//        }];
//
    [self.resetGameCommand.executionSignals subscribeNext:^(id x) {
        NSLog(@"executionsignals %@", x);
    }];
    
    [self.resetGameCommand.executing subscribeNext:^(id x) {
        NSLog(@"executing %@", x);
    }];
    
    RACSignal* initialMatrixSignal = [[[[[self.resetGameCommand.executionSignals logNext]
        filter:^BOOL(id value) {
            return (self.matrix == nil);
        }]
        mapReplace:emptyMatrix()]
        named:@"initialMatrix"] logNext];
    
    RACSignal* initialTilesSignal = [[[initialMatrixSignal
        map:^(RTTMatrix* matrix) {
            RTTTile* firstRandomTile = matrix.getNewRandomTile();
            RTTTile* secondRandomTile = matrix.applyReduceCommands(@[firstRandomTile]).getNewRandomTile();
            return @[firstRandomTile, secondRandomTile];
        }] named:@"initialTiles"] logNext];

    RACSignal* anyMatrixSignal = [[[RACSignal merge:@[initialMatrixSignal, matrixSignal]]
                                  named:@"anyMatrix"] logNext];
    
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
    RACSignal* swipeSignal = [[[RACSignal merge:signalArray] named:@"swipes"] logNext];

    // map the directions to animation vectors
    RACSignal* vectorsSignal = [[[[RACSignal
        combineLatest:@[swipeSignal, anyMatrixSignal]
        reduce:^id(NSNumber* direction, RTTMatrix* matrix) {
            return matrix.mapDirectionToReduceVectors(direction);
        }]
        filter:^BOOL(NSArray* vectors) {
            return [vectors count] > 0;
        }]
        named:@"vectors"] logNext];

    // apply the changes to the matrix
    RACSignal* reducedMatrixSignal = [[[RACSignal
        combineLatest:@[vectorsSignal,
                        anyMatrixSignal]
        reduce:^id(NSArray* vectors, RTTMatrix* matrix) {
            return matrix.applyReduceCommands(vectors);
        }] named:@"reducedMatrix"] logNext];

    RACSignal* tileViewsToMoveSignal = [[[[[vectorsSignal
        map:^NSArray*(NSArray* vectors) {
            NSArray* tileViewsToMove = [[[vectors.rac_sequence
                map:^id(RTTVector* v) {
                    return v.from;
                }]
                map:firstTileViewsForPoint]
                array];
            return tileViewsToMove;
        }]
        doNext:^(NSArray* tileViews) {
            // remove old tileviewss
            for (RTTTileView* tileView in tileViews) {
                [tileView removeFromSuperview];
            }
        }]
        zipWith:vectorsSignal]
        map:^NSArray*(RACTuple* tuple) {
            // create replace tiles, copy frame and change point, because tileviews are immutables
            NSArray* views = tuple.first;
            NSArray* vectors = tuple.second;
            
            NSArray* movedTileViews = [[[views.rac_sequence
                zipWith:vectors.rac_sequence]
                map:^id(RACTuple* tuple) {
                    RTTTileView* tileView = tuple.first;
                    RTTVector* vector = tuple.second;
                    
                    RTTTileView* replaceTileView = mapTileToTileView(tile(vector.to, tileView.value));
                    replaceTileView.frame = tileView.frame;
                    return replaceTileView;
                }]
                array];
            return movedTileViews;
        }]
        doNext:^(NSArray* tileViews) {
            for (RTTTileView* tileView in tileViews) {
                [gameView insertSubview:tileView atIndex:0];
            }
        }];
    
    
    RACSignal* mergePointsSignal = [vectorsSignal
        map:^NSArray*(NSArray* vectors) {
            NSArray* mergePoints = [[[vectors.rac_sequence
                filter:^BOOL(RTTVector* v) {
                    return [v isMerge];
                }]
                map:^id(RTTVector* v) {
                    return v.to;
                }]
                array];
            
            return [mergePoints sortedArrayUsingSelector:@selector(compare:)];
        }];

    
    // collect tiles to remove after merge
    RACSignal* tileViewsToDiscardSignal = [mergePointsSignal
        map:^NSArray*(NSArray* mergePoints) {
            NSArray* tileViewsToDiscard = [[mergePoints.rac_sequence
                map:mapTileViewsForPoint]
                array];
            return tileViewsToDiscard;
        }];
    
    // get merged tiles
    RACSignal* tileViewsToMergeSignal = [RACSignal
        combineLatest:@[mergePointsSignal, reducedMatrixSignal]
        reduce:^id(NSArray* mergePoints, RTTMatrix* reducedMatrix) {
            NSArray* tileViewsToMerge = [[[mergePoints.rac_sequence
                map:^id(RTTPoint* point) {
                    return tile(point, reducedMatrix.valueAt(point));
                }]
                map:mapTileToTileView]
                array];
            return tileViewsToMerge;
        }];
    
    
    // after every swipe add one random tile to the signal stream
    RACSignal* randomTileSignal = [[reducedMatrixSignal
        map:^id(RTTMatrix* reducedMatrix) {
            return @[reducedMatrix.getNewRandomTile()];
        }]
        named:@"randomTile"];

    RACSignal* tilesToCreateSignal = [[[RACSignal
        merge:@[initialTilesSignal, randomTileSignal]]
        named:@"tilesToCreate"] logNext];
    
    RACSignal* updatedMatrixSignal = [[[RACSignal
        combineLatest:@[reducedMatrixSignal, tilesToCreateSignal]
        reduce:^RTTMatrix*(RTTMatrix* matrix, NSArray* tiles) {
            return matrix.applyReduceCommands(tiles);
        }]
        named:@"updatedMatrix"] logNext];
    
    RACSignal* tileViewsToCreateSignal = [tilesToCreateSignal
//        doNext:^(NSArray* tiles) {
//            self.matrix = self.matrix.applyReduceCommands(tiles);
//        }]
        map:^NSArray*(NSArray* tiles) {
            return [[tiles.rac_sequence map:mapTileToTileView] array];
        }];
    
    [tileViewsToCreateSignal
        subscribeNext:^(NSArray* tileViewsToCreate) {
            // create animations
            for (RTTTileView* tileView in tileViewsToCreate) {
                tileView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                tileView.alpha = 0.0f;
                [gameView addSubview:tileView];
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
        }];
    
    [[RACSignal
        combineLatest:@[tileViewsToCreateSignal,
                        tileViewsToMoveSignal,
                        tileViewsToMergeSignal,
                        tileViewsToDiscardSignal]]
        subscribeNext:^(RACTuple* tuple) {
            NSArray* tvCreate = tuple.first;
            NSArray* tvMove = tuple.second;
            NSArray* tvMerge = tuple.third;
            NSArray* tvDiscard = tuple.fourth;
            
            [self animateTileViewsToCreate:tvCreate
                                      move:tvMove
                                     merge:tvMerge
                                   discard:tvDiscard
                                    inView:gameView];
        }];

    
/*
    // do the animations either if event arrives from swipe or from reset button
    vectorSignal = [RACSignal merge:@[vectorSignal, initialTilesSignal]];

    // animations as side effects
    tilesAndVectorsSignal = [tilesAndVectorsSignal doNext:^(NSArray* vectors) {
        NSLog(@"vectors: %@", vectors);
        NSArray* moves = vectors.filterMoves();
        NSArray* creates = vectors.filterCreates();
        NSArray* merges = moves.filterMergePoints();

        RTTMatrix* reducedMatrix = self.matrix.applyReduceCommands(vectors);

        // moves
//        NSArray* tileViewsToMove = [[[moves.rac_sequence
//            map:^id(RTTVector* vector) {
//                return vector.from;
//            }]
//            map:firstTileViewsForPoint]
//            array];
//
//        // remove old tileviewss
//        for (RTTTileView* tileView in tileViewsToMove) {
//            [tileView removeFromSuperview];
//        }
//
//        // create replace tiles, copy frame and change point, because tileviews are immutables
//        tileViewsToMove = [[[moves.rac_sequence
//            zipWith:tileViewsToMove.rac_sequence]
//            map:^id(RACTuple* tuple) {
//                RTTVector* vector = tuple.first;
//                RTTTileView* tileView = tuple.second;
//
//                RTTTileView* replaceTileView = mapTileToTileView(tile(vector.to, tileView.value));
//                replaceTileView.frame = tileView.frame;
//                return replaceTileView;
//            }]
//            array];
//
//        for (RTTTileView* tileView in tileViewsToMove) {
//            [gameView insertSubview:tileView atIndex:0];
//        }

//        // collect tiles to remove after merge
//        NSArray* tileViewsToDiscard = [[[merges.rac_sequence
//            map:mapTileViewsForPoint]
//            flatten]
//            array];

//        // get merged tiles
//        NSArray* tileViewsToMerge = [[[merges.rac_sequence
//            map:^id(RTTPoint* point) {
//                return tile(point, reducedMatrix.valueAt(point));
//            }]
//            map:mapTileToTileView]
//            array];

//        // get to creat tileviews
//        NSArray* tileViewsToCreate = [[creates.rac_sequence
//            map:mapTileToTileView]
//            array];

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
*/
    [[[[matrixSignal
        map:^id(RTTMatrix* matrix) {
            return @(matrix.isOver());
        }]
        ignore:@NO]
        delay:kSlideAnimDuration + kScaleAnimDuration]
        subscribeNext:^(id x) {
            [UIView animateWithDuration:kSlideAnimDuration * 4.0f animations:^{
                gameOverView.alpha = 1.0f;
            }];
        }];

    // use signals

    // assign the new matrix to itself
    RAC(self, matrix) = updatedMatrixSignal;

    // log
    [matrixSignal
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
//    // create animations
//    for (RTTTileView* tileView in tileViewsToCreate) {
//        tileView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
//        tileView.alpha = 0.0f;
//        [container addSubview:tileView];
//    }
//    [UIView animateWithDuration:kScaleAnimDuration
//                          delay:kSlideAnimDuration
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         for (RTTTileView* tileView in tileViewsToCreate) {
//                             tileView.alpha = 1.0f;
//                             tileView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                         }
//                     }
//                     completion:nil];

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



//    RACSignal* tileViewsToMoveSignal = [[[[[[vectorsSignal
//        map:^id(RTTVector* v) {
//            return v.from;
//        }]
//        map:firstTileViewsForPoint]
//        doNext:^(RTTTileView* tv) {
//            // remove old tileviews
//            [tv removeFromSuperview];
//        }]
//        zipWith:vectorsSignal]
//        map:^id(RACTuple* tuple) {
//            // create replace tiles, copy frame and change point, because tileviews are immutables
//            RTTTileView* tileView = tuple.first;
//            RTTVector* vector = tuple.second;
//
//            RTTTileView* replaceTileView = mapTileToTileView(tile(vector.to, tileView.value));
//            replaceTileView.frame = tileView.frame;
//            return replaceTileView;
//        }]
//        doNext:^(RTTTileView* tv) {
//            [gameView insertSubview:tv atIndex:0];
//        }];
//



