//
// Created by Viktor Belenyesi on 07/03/14.
// Copyright (c) 2014 Viktor Belenyesi. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "RTTMatrix.h"
#import "RTTPoint.h"

SPEC_BEGIN(MatrixSpec)

describe(@"Matrix", ^{
    __block RTTMatrix* sut = nil;
    __block const RTTPoint*p00 = point(0, 0);
    __block const RTTPoint* p10 = point(1, 0);
    __block const RTTPoint* p01 = point(0, 1);
    __block const RTTPoint* p20 = point(2, 0);
    __block const RTTPoint* p30 = point(3, 0);


    beforeEach(^{
        sut = emptyMatrix();
    });
    
    afterEach(^{
        sut = nil;
    });
    
    it(@"empty emptyMatrix", ^{
        // then
        for (short y = 0; y < kMatrixSize; y++) {
            for (short x = 0; x < kMatrixSize; x++) {
                [[theValue(sut.valueAt(point(x, y))) should] equal:@0];
            }
        }
    });

    context(@"transpose", ^{

        it(@"empty", ^{
            // when
            sut = sut.transpose();

            // then
            [[sut should] equal:emptyMatrix()];
        });

        it(@"once", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            sut = sut.transpose();

            // then
            [[sut should] equal:emptyMatrix().addValue(p00, 2).addValue(p01, 4)];
        });

        it(@"twice", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            RTTMatrix* transposed = sut.transpose().transpose();

            // then
            [[sut should] equal:transposed];
        });

    });

    context(@"reverse rowwise", ^{

        it(@"empty", ^{
            // when
            sut = sut.reverseRowWise();

            // then
            [[sut should] equal:emptyMatrix()];
        });

        it(@"once", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            sut = sut.reverseRowWise();

            // then
            [[sut should] equal:emptyMatrix().addValue(p20, 4).addValue(p30, 2)];
        });

        it(@"twice", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            RTTMatrix* reversed = sut.reverseRowWise().reverseRowWise();

            // then
            [[sut should] equal:reversed];
        });

    });

    context(@"rotate right", ^{

        it(@"empty", ^{
            // when
            sut = sut.rotateRight();

            // then
            [[sut should] equal:emptyMatrix()];
        });

        it(@"once", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            sut = sut.rotateRight();

            // then
            [[sut should] equal:emptyMatrix().addValue(p30, 2).addValue(point(3, 1), 4)];
        });

        it(@"identity", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(p10, 4);

            // when
            RTTMatrix* rotated = sut.rotateRight().rotateRight().rotateRight().rotateRight();

            // then
            [[sut should] equal:rotated];
        });

    });
    
    context(@"substract", ^{

        it(@"simple", ^{
            // given
            sut = sut.addValue(p00, 2);

            // when
            sut = sut.substractValue(p00, 2);

            // then
            [[sut should] equal:emptyMatrix()];
        });

        it(@"complex", ^{
            // given
            sut = sut.addValue(p00, 2).addValue(point(1, 1), 4);

            // when
            sut = sut.substractValue(p00, 2);

            // then
            [[sut should] equal:emptyMatrix().addValue(point(1, 1), 4)];
        });

    });

    context(@"add", ^{

        it(@"basic", ^{
            // given
            // when
            sut = sut.addValue(p00, 2);

            // then
            [[theValue(sut.valueAt(p00)) should] equal:@2];
        });

        it(@"assymetric", ^{
            // given
            // when
            sut = sut.addValue(point(0, 3), 2);

            // then
            [[theValue(sut.valueAt(point(0, 3))) should] equal:@2];
        });

    });

    context(@"is equal to", ^{
        it(@"self", ^{
            // then
            [[sut should] equal:sut];
        });

        it(@"another empty", ^{
            // then
            [[sut should] equal:emptyMatrix()];
        });

        it(@"non empty", ^{
            // given
            sut = sut.addValue(point(3, 2), 2);

            // when
            RTTMatrix* otherMatrix = emptyMatrix().addValue(point(3, 2), 2);

            // then
            [[sut should] equal:otherMatrix];
        });

        it(@"negative", ^{
            // when
            sut = sut.addValue(point(3, 2), 2);

            // then
            [[sut shouldNot] equal:emptyMatrix()];
        });

    });

    context(@"get row", ^{

        beforeEach(^{
            for (short y = 0; y < kMatrixSize; y++) {
                for (short x = 0; x < kMatrixSize; x++) {
                    sut = sut.addValue(point(x, y), 1 << (y * kMatrixSize + (x + 1)));
                }
            }
        });

        it(@"can get the first row", ^{
            // then
            for (short x = 0; x < kMatrixSize; x++) {
                [[theValue(sut.valueAt(point(x, 0))) should] equal:@(1 << (x + 1))];
            }
        });

        it(@"can get the second row", ^{
            // then
            for (short x = 0; x < kMatrixSize; x++) {
                [[theValue(sut.valueAt(point(x, 1))) should] equal:@(1 << (x + 1 + kMatrixSize))];
            }
        });

    });

    context(@"reduce", ^{
        __block RTTMatrix* reduced = nil;

        afterEach(^{
           reduced = nil;
        });

        context(@"from right", ^{

            it(@"empty", ^{
                // given
                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[sut should] equal:reduced];
            });

            it(@"one value, reduce nothing", ^{
                // given
                sut = sut.addValue(p00, 2);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[sut should] equal:reduced];
            });

            it(@"one value, reduce one", ^{
                // given
                sut = sut.addValue(p10, 2);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 2)];
            });

            it(@"two different values, neighbors, reduce nothing", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[sut should] equal:reduced];
            });

            it(@"two different values, reduce the gap", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p20, 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 2).addValue(p10, 4)];
            });

            it(@"reduce one pair, neighbors", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4)];
            });

            it(@"reduce one pair plus one, neighbors", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(p20, 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p10, 4)];
            });

            it(@"reduce one pair plus one, neighbors with a gap", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(p30, 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p10, 4)];
            });

            it(@"reduce two different pairs", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(p20, 4).addValue(p30, 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p10, 8)];
            });

            it(@"reduce two similar pairs", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(p20, 2).addValue(p30, 2);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p10, 4)];
            });

            it(@"reduce multiple rows", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(point(1, 1), 4).addValue(point(3, 1), 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionLeft)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p01, 8)];
            });

        });

        context(@"from bottom", ^{

            it(@"reduce multiple rows", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p01, 2).addValue(p10, 4).addValue(point(1, 3), 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionUp)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p00, 4).addValue(p10, 8)];
            });

        });

        context(@"from left", ^{

            it(@"reduce multiple rows", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(p10, 2).addValue(point(1, 1), 4).addValue(point(3, 1), 4);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionRight)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(p30, 4).addValue(point(3, 1), 8)];
            });

        });

        context(@"from top", ^{

            it(@"reduce multiple rows", ^{
                // given
                sut = sut.addValue(p00, 2).addValue(point(0, 3), 2).addValue(point(1, 1), 4).addValue(point(1, 2), 8);

                // when
                reduced = sut.applyReduceVectors(sut.mapDirectionToReduceVectors(@(UISwipeGestureRecognizerDirectionDown)));

                // then
                [[reduced should] equal:emptyMatrix().addValue(point(0, 3), 4).addValue(point(1, 3), 8).addValue(point(1, 2), 4)];
            });

        });

    });

    context(@"empty positions", ^{

        it(@"empty emptyMatrix", ^{
            // then
            [[emptyMatrix().getEmptyPositions() should] haveCountOf:(NSUInteger) (kMatrixSize * kMatrixSize)];
        });

        it(@"one element", ^{
            // when
            sut = emptyMatrix().addValue(p00, 2);

            // then
            [[sut.getEmptyPositions() should] haveCountOf:(NSUInteger) (kMatrixSize * kMatrixSize - 1)];
        });

        it(@"two elements", ^{
            // when
            sut = emptyMatrix().addValue(p00, 2).addValue(p01, 4);

            // then
            [[sut.getEmptyPositions() should] haveCountOf:(NSUInteger) (kMatrixSize * kMatrixSize - 2)];
        });

    });

    context(@"is ended", ^{
        __block RTTMatrix* fullMatrix = nil;

        beforeEach(^{
            fullMatrix = emptyMatrix();
            for (short y = 0; y < kMatrixSize; y++) {
                for (short x = 0; x < kMatrixSize; x++) {
                    fullMatrix = fullMatrix.addValue(point(x, y), (1 << (y * kMatrixSize + (x + 1))));
                }
            }
        });

        afterEach(^{
            fullMatrix = nil;
        });

        it(@"empty emptyMatrix", ^{
            // then
            [[theValue(emptyMatrix().isOver()) should] beNo];
        });

        it(@"one element", ^{
            // when
            sut = emptyMatrix().addValue(p00, 2);

            // then
            [[theValue(emptyMatrix().isOver()) should] beNo];
        });

        it(@"full, one horizontal pair", ^{
            // when
            fullMatrix = fullMatrix.addValue(p00, 2);

            // then
            [[theValue(fullMatrix.isOver()) should] beNo];
        });

        it(@"full, one horizontal pair, end of row", ^{
            // when
            fullMatrix = fullMatrix.addValue(p20, 8);

            // then
            [[theValue(fullMatrix.isOver()) should] beNo];
        });

        it(@"full, one vertical pair", ^{
            // when
            fullMatrix = fullMatrix.addValue(p00, 30);

            // then
            [[theValue(fullMatrix.isOver()) should] beNo];
        });

        it(@"full, one vertical pair end of row", ^{
            // when
            fullMatrix = fullMatrix.addValue(p30, 240);

            // then
            [[theValue(fullMatrix.isOver()) should] beNo];
        });

        it(@"full, all different", ^{
            // then
            [[theValue(fullMatrix.isOver()) should] beYes];
        });

    });
});

SPEC_END
