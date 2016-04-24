//
//  GHTestWindowController.m
//  GHKit
//
//  Created by Gabriel Handford on 1/17/09.
//  Copyright 2009. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "GHTestWindowController.h"


@implementation GHTestWindowController

@synthesize viewController=viewController_;

- (id)init {
	return [super initWithWindowNibName:@"GHTestWindow"];
}

- (void)awakeFromNib {	
	viewController_ = [[GHTestViewController alloc] init];
	[viewController_ loadTestSuite];
	[viewController_ loadDefaults];	
	self.window.contentView = viewController_.view;	
	NSString *bundleVersion = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.window.title = [NSString stringWithFormat:@"GHUnit %@", bundleVersion];	
  
  if (getenv("GHUNIT_AUTORUN")) [self runTests:nil];
}

- (IBAction)runTests:(id)sender {
  [viewController_ runTests];
}

- (IBAction)copy:(id)sender {
  [viewController_ copy:sender];
}


- (void)windowWillClose:(NSNotification *)notification {
	[[NSApplication sharedApplication] terminate:self];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
  if ([viewController_ isShowingDetails] && frameSize.width < MIN_WINDOW_WIDTH) return sender.frame.size;
  return frameSize;
}

@end
