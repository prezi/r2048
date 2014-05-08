//
// Created by Viktor Belenyesi on 07/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSArray+RTTTiles.h"
#import "NSArray+RTTVectors.h"
#import "RTTPoint.h"
#import "RTTTile.h"
#import "RTTVector.h"

SPEC_BEGIN(VectorSpec)

describe(@"Vector", ^{
    
    __block RTTPoint* p00 = point(0, 0);
    __block RTTPoint* p10 = point(1, 0);
    __block RTTPoint* p20 = point(2, 0);
    __block RTTPoint* p30 = point(3, 0);

    context(@"rotation", ^ {

        it(@"90", ^{
            // given
            RTTVector* v = vector(point(1, 0), point(2, 0));

            // when
            v = v.rotateRight();

            // then
            [[v should] equal:vector(point(3, 1), point(3, 2))];
        });

        it(@"180", ^{
            // given
            RTTVector* v = vector(point(1, 0), point(2, 0));

            // when
            v = v.rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(2, 3), point(1, 3))];
        });

        it(@"270", ^{
            // given
            RTTVector* v = vector(point(1, 0), point(2, 0));

            // when
            v = v.rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(0, 2), point(0, 1))];
        });

        it(@"360", ^{
            // given
            RTTVector* v = vector(point(1, 0), point(2, 0));

            // when
            v = v.rotateRight().rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(1, 0), point(2, 0))];
        });

        it(@"long 90", ^{
            // given
            RTTVector* v = vector(point(0, 0), point(3, 0));

            // when
            v = v.rotateRight();

            // then
            [[v should] equal:vector(point(3, 0), point(3, 3))];
        });

        it(@"long 180", ^{
            // given
            RTTVector* v = vector(point(0, 0), point(3, 0));

            // when
            v = v.rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(3, 3), point(0, 3))];
        });

        it(@"long 270", ^{
            // given
            RTTVector* v = vector(point(0, 0), point(3, 0));

            // when
            v = v.rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(0, 3), point(0, 0))];
        });

        it(@"long 360", ^{
            // given
            RTTVector* v = vector(point(0, 0), point(3, 0));

            // when
            v = v.rotateRight().rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(0, 0), point(3, 0))];
        });

        it(@"assymetric 90", ^{
            // given
            RTTVector* v = vector(point(1, 1), point(3, 1));

            // when
            v = v.rotateRight();

            // then
            [[v should] equal:vector(point(2, 1), point(2, 3))];
        });

        it(@"assymetric 180", ^{
            // given
            RTTVector* v = vector(point(1, 1), point(3, 1));

            // when
            v = v.rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(2, 2), point(0, 2))];
        });

        it(@"assymetric 270", ^{
            // given
            RTTVector* v = vector(point(1, 1), point(3, 1));

            // when
            v = v.rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(1, 2), point(1, 0))];
        });

        it(@"assymetric 360", ^{
            // given
            RTTVector* v = vector(point(1, 1), point(3, 1));

            // when
            v = v.rotateRight().rotateRight().rotateRight().rotateRight();

            // then
            [[v should] equal:vector(point(1, 1), point(3, 1))];
        });

    });

    context(@"reduce vectors", ^{
        __block NSArray *result = nil;

        afterEach(^{
            result = nil;
        });

        it(@"empty", ^{
            // when
            result = @[].mapTileArrayToReduceVectors();

            // then
            [[result should] beEmpty];
        });

        it(@"one element, can't reduce", ^{
            // when
            result = @[tile(p00, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] beEmpty];
        });

        it(@"one element, can reduce", ^{
            // when
            result = @[tile(p10, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p10, p00)];
        });

        it(@"two different elements, neighbours", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] beEmpty];
        });

        it(@"two different elements, gap", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p20, p10)];
        });

        it(@"one pair, neighbours", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p10, p00)];
        });

        it(@"one pair, gap", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p20, p00)];
        });

        it(@"one pair, two gaps", ^{
            // when
            result = @[tile(p10, 2), tile(p30, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p30, p00)];
        });

        it(@"one pair + different, no gap", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p10)];
        });

        it(@"one pair + different, gap inside the pair", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 2), tile(p30, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:vector(p20, p00)];
            [[result[1] should] equal:vector(p30, p10)];
        });

        it(@"one pair + different, gap after the pair", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p30, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p30, p10)];
        });

        it(@"one pair + different, gap first", ^{
            // when
            result = @[tile(p10, 2), tile(p20, 2), tile(p30, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:3];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p00)];
            [[result[2] should] equal:vector(p30, p10)];
        });

        it(@"different + one pair, no gap", ^{
            // when
            result = @[tile(p00, 4), tile(p10, 2), tile(p20, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p20, p10)];
        });

        it(@"different + one pair, gap before the pair", ^{
            // when
            result = @[tile(p10, 4), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:3];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p10)];
            [[result[2] should] equal:vector(p30, p10)];
        });

        it(@"different + one pair, gap inside the pair", ^{
            // when
            result = @[tile(p00, 4), tile(p10, 2), tile(p30, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:vector(p30, p10)];
        });

        it(@"different + one pair, gap first", ^{
            // when
            result = @[tile(p10, 4), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:3];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p10)];
            [[result[2] should] equal:vector(p30, p10)];
        });

        it(@"two pairs similar", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:3];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p10)];
            [[result[2] should] equal:vector(p30, p10)];
        });

        it(@"two pairs different", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 4), tile(p30, 4)].mapTileArrayToReduceVectors();

            // then
            [[result should] haveCountOf:3];
            [[result[0] should] equal:vector(p10, p00)];
            [[result[1] should] equal:vector(p20, p10)];
            [[result[2] should] equal:vector(p30, p10)];
        });

    });

    context(@"merge score", ^{
        __block NSArray *result = nil;

        afterEach(^{
            result = nil;
        });

        it(@"empty", ^{
            // when
            result = @[].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] beEmpty];
        });

        it(@"one element, can't reduce", ^{
            // when
            result = @[tile(p00, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] beEmpty];
        });

        it(@"one element, can reduce", ^{
            // when
            result = @[tile(p10, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] beEmpty];
        });

        it(@"two different elements, neighbours", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] beEmpty];
        });

        it(@"two different elements, gap", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] beEmpty];
        });

        it(@"one pair, neighbours", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair, gap", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair, two gaps", ^{
            // when
            result = @[tile(p10, 2), tile(p30, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair + different, no gap", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair + different, gap inside the pair", ^{
            // when
            result = @[tile(p00, 2), tile(p20, 2), tile(p30, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair + different, gap after the pair", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p30, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"one pair + different, gap first", ^{
            // when
            result = @[tile(p10, 2), tile(p20, 2), tile(p30, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p00];
        });

        it(@"different + one pair, no gap", ^{
            // when
            result = @[tile(p00, 4), tile(p10, 2), tile(p20, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p10];
        });

        it(@"different + one pair, gap before the pair", ^{
            // when
            result = @[tile(p10, 4), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p10];
        });

        it(@"different + one pair, gap inside the pair", ^{
            // when
            result = @[tile(p00, 4), tile(p10, 2), tile(p30, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:1];
            [[result[0] should] equal:p10];
        });

        it(@"different + one pair, gap first", ^{
            // when
            result = @[tile(p10, 4), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result[0] should] equal:p10];
        });

        it(@"two pairs similar", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 2), tile(p30, 2)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:p00];
            [[result[1] should] equal:p10];
        });

        it(@"two pairs different", ^{
            // when
            result = @[tile(p00, 2), tile(p10, 2), tile(p20, 4), tile(p30, 4)].mapTileArrayToReduceVectors().filterMergePoints();

            // then
            [[result should] haveCountOf:2];
            [[result[0] should] equal:p00];
            [[result[1] should] equal:p10];
        });

    });
    
});

SPEC_END
