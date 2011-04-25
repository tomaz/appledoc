//
//  DemoTokensViewController.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/2/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "DemoTokensViewController.h"
#import <ParseKit/ParseKit.h>
#import "PKParseTreeView.h"

@interface DemoTokensViewController ()
- (void)doParse;
- (void)done;
@end

@implementation DemoTokensViewController

- (id)init {
    return [self initWithNibName:@"TokensView" bundle:nil];
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b {
    if (self = [super initWithNibName:name bundle:b]) {
        self.tokenizer = [[[PKTokenizer alloc] init] autorelease];
        
        [tokenizer.symbolState add:@"::"];
        [tokenizer.symbolState add:@"<="];
        [tokenizer.symbolState add:@">="];
        [tokenizer.symbolState add:@"=="];
        [tokenizer.symbolState add:@"!="];
        [tokenizer.symbolState add:@"+="];
        [tokenizer.symbolState add:@"-="];
        [tokenizer.symbolState add:@"*="];
        [tokenizer.symbolState add:@"/="];
        [tokenizer.symbolState add:@":="];
        [tokenizer.symbolState add:@"++"];
        [tokenizer.symbolState add:@"--"];
        [tokenizer.symbolState add:@"<>"];
        [tokenizer.symbolState add:@"=:="];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.inString = nil;
    self.outString = nil;
    self.tokString = nil;
    self.toks = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSString *s = [NSString stringWithFormat:@"%C", 0xab];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:s];
    [tokenField setTokenizingCharacterSet:set];
}


- (IBAction)parse:(id)sender {
    if (![inString length]) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    //[self doParse];
    [NSThread detachNewThreadSelector:@selector(doParse) toTarget:self withObject:nil];
}


- (void)doParse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //self.tokenizer = [PKTokenizer tokenizer];
    self.tokenizer.string = self.inString;
    
    
    self.toks = [NSMutableArray array];
    PKToken *tok = nil;
    PKToken *eof = [PKToken EOFToken];
    while (eof != (tok = [tokenizer nextToken])) {
        [toks addObject:tok];
    }
    
    [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
    
    [pool drain];
}


- (void)done {
    NSMutableString *s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@ %C", tok.stringValue, 0xab];
    }
    self.tokString = [[s copy] autorelease];
    
    s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@\n", [tok debugDescription]];
    }
    self.outString = [[s copy] autorelease];
    self.busy = NO;
}

@synthesize tokenizer;
@synthesize inString;
@synthesize outString;
@synthesize tokString;
@synthesize toks;
@synthesize busy;
@end
