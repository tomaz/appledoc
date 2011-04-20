//
//  PKCommentStateTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/28/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDCommentStateTest : SenTestCase {
    PKCommentState *commentState;
    PKReader *r;
    PKTokenizer *t;
    NSString *s;
    PKToken *tok;
}

@end
