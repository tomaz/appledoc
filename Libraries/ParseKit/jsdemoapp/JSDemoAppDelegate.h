//
//  JSDemoAppDelegate.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 1/10/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface JSDemoAppDelegate : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet WebView *webView;
    IBOutlet NSTextField *comboBox;
}
- (IBAction)goToLocation:(id)sender;
- (IBAction)openLocation:(id)sender;
- (IBAction)collect:(id)sender;
- (IBAction)showConsole:(id)sender;

@property (nonatomic, retain) WebView *webView;
@end
