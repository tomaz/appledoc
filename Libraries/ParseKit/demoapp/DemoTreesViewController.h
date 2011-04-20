//
//  DemoTreesViewController.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PKParseTreeView;
@class TDSourceCodeTextView;

@interface DemoTreesViewController : NSViewController {
    IBOutlet TDSourceCodeTextView *grammarTextView;
    IBOutlet TDSourceCodeTextView *inputTextView;
    IBOutlet PKParseTreeView *parseTreeView;    

    NSString *grammarString;
    NSString *inString;
    BOOL busy;
}

- (IBAction)parse:(id)sender;

@property (retain) NSString *grammarString;
@property (retain) NSString *inString;
@property BOOL busy;
@end
