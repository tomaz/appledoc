//
//  PKArithmeticParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDArithmeticParserTest.h"

@implementation TDArithmeticParserTest

- (void)setUp {
    p = [TDArithmeticParser parser];
}


- (void)testOne {
    s = @"1";
    result = [p parse:s];
    TDEquals((double)1.0, result);
}


- (void)testFortySeven {
    s = @"47";
    result = [p parse:s];
    TDEquals((double)47.0, result);
}


- (void)testNegativeZero {
    s = @"-0";
    result = [p parse:s];
    TDEquals((double)-0.0, result);
}


- (void)testNegativeOne {
    s = @"-1";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testOnePlusOne {
    s = @"1 + 1";
    result = [p parse:s];
    TDEquals((double)2.0, result);
}


- (void)testOnePlusNegativeOne {
    s = @"1 + -1";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testNegativeOnePlusOne {
    s = @"-1 + 1";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testOneHundredPlusZero {
    s = @"100 + 0";
    result = [p parse:s];
    TDEquals((double)100.0, result);
}


- (void)testNegativeOnePlusZero {
    s = @"-1 + 0";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testNegativeZeroPlusZero {
    s = @"-0 + 0";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testNegativeZeroPlusNegativeZero {
    s = @"-0 + -0";
    result = [p parse:s];
    TDEquals((double)-0.0, result);
}


- (void)testOneMinusOne {
    s = @"1 - 1";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testOneMinusNegativeOne {
    s = @"1 - -1";
    result = [p parse:s];
    TDEquals((double)2.0, result);
}


- (void)testNegativeOneMinusOne {
    s = @"-1 - 1";
    result = [p parse:s];
    TDEquals((double)-2.0, result);
}


- (void)testOneHundredMinusZero {
    s = @"100 - 0";
    result = [p parse:s];
    TDEquals((double)100.0, result);
}


- (void)testNegativeOneMinusZero {
    s = @"-1 - 0";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testNegativeZeroMinusZero {
    s = @"-0 - 0";
    result = [p parse:s];
    TDEquals((double)-0.0, result);
}


- (void)testNegativeZeroMinusNegativeZero {
    s = @"-0 - -0";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testOneTimesOne {
    s = @"1 * 1";
    result = [p parse:s];
    TDEquals((double)1.0, result);
}


- (void)testTwoTimesFour {
    s = @"2 * 4";
    result = [p parse:s];
    TDEquals((double)8.0, result);
}


- (void)testOneTimesNegativeOne {
    s = @"1 * -1";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testNegativeOneTimesOne {
    s = @"-1 * 1";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testOneHundredTimesZero {
    s = @"100 * 0";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testNegativeOneTimesZero {
    s = @"-1 * 0";
    result = [p parse:s];
    TDEquals((double)-0.0, result);
}


- (void)testNegativeZeroTimesZero {
    s = @"-0 * 0";
    result = [p parse:s];
    TDEquals((double)-0.0, result);
}


- (void)testNegativeZeroTimesNegativeZero {
    s = @"-0 * -0";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)testOneDivOne {
    s = @"1 / 1";
    result = [p parse:s];
    TDEquals((double)1.0, result);
}


- (void)testTwoDivFour {
    s = @"2 / 4";
    result = [p parse:s];
    TDEquals((double)0.5f, result);
}


- (void)testFourDivTwo {
    s = @"4 / 2";
    result = [p parse:s];
    TDEquals((double)2.0, result);
}


- (void)testOneDivNegativeOne {
    s = @"1 / -1";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testNegativeOneDivOne {
    s = @"-1 / 1";
    result = [p parse:s];
    TDEquals((double)-1.0, result);
}


- (void)testOneHundredDivZero {
    s = @"100 / 0";
    result = [p parse:s];
    TDEquals((double)INFINITY, result);
}


- (void)testNegativeOneDivZero {
    s = @"-1 / 0";
    result = [p parse:s];
    TDEquals((double)-INFINITY, result);
}


- (void)testNegativeZeroDivZero {
    s = @"-0 / 0";
    result = [p parse:s];
    TDEquals((double)NAN, result);
}


- (void)testNegativeZeroDivNegativeZero {
    s = @"-0 / -0";
    result = [p parse:s];
    TDEquals((double)NAN, result);
}


- (void)test1Exp1 {
    s = @"1 ^ 1";
    result = [p parse:s];
    TDEquals((double)1.0, result);
}


- (void)test1Exp2 {
    s = @"1 ^ 2";
    result = [p parse:s];
    TDEquals((double)1.0, result);
}


- (void)test9Exp2 {
    s = @"9 ^ 2";
    result = [p parse:s];
    TDEquals((double)81.0, result);
}


- (void)test9ExpNegative2 {
    s = @"9 ^ -2";
    result = [p parse:s];
    TDEquals((double)9.0, result);
}


#pragma mark -
#pragma mark Associativity

- (void)test7minus3minus1 { // minus associativity
    s = @"7 - 3 - 1";
    result = [p parse:s];
    TDEquals((double)3.0, (double)result);
}


- (void)test9exp2minus81 { // exp associativity
    s = @"9^2 - 81";
    result = [p parse:s];
    TDEquals((double)0.0, result);
}


- (void)test2exp1exp4 { // exp
    s = @"2 ^ 1 ^ 4";
    result = [p parse:s];
    TDEquals((double)2.0, result);
}


- (void)test100minus5exp2times3 { // exp
    s = @"100 - 5^2*3";
    result = [p parse:s];
    TDEquals((double)25.0, result);
}


- (void)test100minus25times3 { // precedence
    s = @"100 - 25*3";
    result = [p parse:s];
    STAssertEqualsWithAccuracy((double)25.0, result, 1.0, @"");
}


- (void)test100minus25times3Parens { // precedence
    s = @"(100 - 25)*3";
    result = [p parse:s];
    TDEquals((double)225.0, result);
}


- (void)test100minus5exp2times3Parens { // precedence
    s = @"(100 - 5^2)*3";
    result = [p parse:s];
    TDEquals((double)225.0, result);
}

@end
