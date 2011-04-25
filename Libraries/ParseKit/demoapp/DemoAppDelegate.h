//
//  DemoAppDelegate.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 7/12/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DemoTokensViewController;
@class DemoTreesViewController;

@interface DemoAppDelegate : NSObject {
    IBOutlet NSTabView *tabView;
    
    DemoTokensViewController *tokensViewController;
    DemoTreesViewController *treesViewController;
}

@property (nonatomic, retain) DemoTokensViewController *tokensViewController;
@property (nonatomic, retain) DemoTreesViewController *treesViewController;
@end
