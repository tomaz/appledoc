//
//  DemoAppDelegate.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/12/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "DemoAppDelegate.h"
#import "DemoTokensViewController.h"
#import "DemoTreesViewController.h"

@implementation DemoAppDelegate

- (void)dealloc {
    self.tokensViewController = nil;
    self.treesViewController = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    self.tokensViewController = [[[DemoTokensViewController alloc] init] autorelease];
    self.treesViewController = [[[DemoTreesViewController alloc] init] autorelease];
    
    NSTabViewItem *item = [tabView tabViewItemAtIndex:0];
    [item setView:[tokensViewController view]];

    item = [tabView tabViewItemAtIndex:1];
    [item setView:[treesViewController view]];
}

@synthesize tokensViewController;
@synthesize treesViewController;
@end
