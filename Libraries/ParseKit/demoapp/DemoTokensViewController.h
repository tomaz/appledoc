//
//  DemoTokensViewController.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PKTokenizer;

@interface DemoTokensViewController : NSViewController {
    IBOutlet NSTokenField *tokenField;

    PKTokenizer *tokenizer;
    NSString *inString;
    NSString *outString;
    NSString *tokString;
    NSMutableArray *toks;
    BOOL busy;
}

- (IBAction)parse:(id)sender;

@property (retain) PKTokenizer *tokenizer;
@property (retain) NSString *inString;
@property (retain) NSString *outString;
@property (retain) NSString *tokString;
@property (retain) NSMutableArray *toks;
@property BOOL busy;
@end
