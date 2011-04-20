//
//  PKScientificNumberState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/25/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/PKNumberState.h>

/*!
    @class      PKScientificNumberState 
    @brief      A <tt>PKScientificNumberState</tt> object returns a number from a reader.
    @details    <p>This state's idea of a number expands on its superclass, allowing an 'e' followed by an integer to represent 10 to the indicated power. For example, this state will recognize <tt>1e2</tt> as equaling <tt>100</tt>.</p>
                <p>This class exists primarily to show how to introduce a new tokenizing state.</p>
*/
@interface PKScientificNumberState : PKNumberState {
    BOOL allowsScientificNotation;
    CGFloat exp;
    BOOL negativeExp;
}

@property (nonatomic) BOOL allowsScientificNotation;
@end
