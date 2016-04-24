//
//  GHTestViewController.m
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

#import "GHTestViewController.h"

#import "GHTesting.h"

@interface GHTestViewController ()
- (void)_updateTest:(id<GHTest>)test;
- (NSString *)_prefix;
- (void)_setPrefix:(NSString *)prefix;
- (void)_updateDetailForTest:(id<GHTest>)test prefix:(NSString *)prefix;
@end

@implementation GHTestViewController

@synthesize suite=suite_, status=status_, statusProgress=statusProgress_, 
wrapInTextView=wrapInTextView_, runLabel=runLabel_, dataSource=dataSource_,
running=running_, exceptionFilename=exceptionFilename_, exceptionLineNumber=exceptionLineNumber_;

- (id)init {
	if ((self = [super initWithNibName:@"GHTestView" bundle:[NSBundle bundleForClass:[GHTestViewController class]]])) { 
		suite_ = [GHTestSuite suiteFromEnv];
    
    NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if (!identifier) identifier = @"Tests";
    GHUDebug(@"Using identifier: %@", identifier);
    
		dataSource_ = [[GHTestOutlineViewModel alloc] initWithIdentifier:identifier suite:suite_];
		dataSource_.delegate = self;
    [dataSource_ loadDefaults];
		[self view]; // Force nib awaken
	}
	return self;
}

- (void)dealloc {
	dataSource_.delegate = nil;
}

- (void)awakeFromNib {
	_outlineView.delegate = dataSource_;
	_outlineView.dataSource = dataSource_;
  
   // If we remove from superview, need to keep it retained
	
	[_textView setTextColor:[NSColor whiteColor]];
	[_textView setFont:[NSFont fontWithName:@"Monaco" size:10.0]];
	[_textView setString:@""];
  _textSegmentedControl.selectedSegment = [[NSUserDefaults standardUserDefaults] integerForKey:@"TextSelectedSegment"];
  
  _splitView.delegate = self;
  
  NSString *prefix = [self _prefix];
  if (prefix) {
    [_searchField setStringValue:prefix];
    [self updateSearchFilter:nil];
  }
  
	self.wrapInTextView = NO;
	self.runLabel = @"Run";
}

- (NSString *)_prefix {
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"Prefix"];
}

- (void)_setPrefix:(NSString *)prefix {
  [[NSUserDefaults standardUserDefaults] setObject:prefix forKey:@"Prefix"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Running

- (IBAction)runTests:(id)sender {
	[self runTests];
}

- (void)runTests {
	if (dataSource_.isRunning) {
		self.status = @"Cancelling...";
		[dataSource_ cancel];
	} else {
		NSAssert(suite_, @"Must set test suite");
		[self loadTestSuite];
		self.status = @"Starting tests...";
		self.runLabel = @"Cancel";
		BOOL inParallel = self.runInParallel;
    BOOL reraiseExceptions = self.reraiseExceptions;
    // TODO(gabe): This is confusing; Choosing reraise over in parallel since can't have both
    if (inParallel && reraiseExceptions) inParallel = NO;
    GHTestOptions options = 0;
    if (self.reraiseExceptions) options |= GHTestOptionReraiseExceptions;
		[dataSource_ run:self inParallel:inParallel options:options];
	}
}

- (void)loadTestSuite {
	self.status = @"Loading tests...";
  [self reload];
	self.status = @"Select 'Run' to start tests";
}

- (void)reload {
  [_outlineView reloadData];
	[_outlineView reloadItem:nil reloadChildren:YES];
	[_outlineView expandItem:nil expandChildren:YES];
}

#pragma mark -

- (void)setWrapInTextView:(BOOL)wrapInTextView {
	wrapInTextView_ = wrapInTextView;
	if (wrapInTextView_) {
		// No horizontal scroll, word wrapping
		[[_textView enclosingScrollView] setHasHorizontalScroller:NO];		
		[_textView setHorizontallyResizable:NO];
		NSSize size = [[_textView enclosingScrollView] frame].size;
		[[_textView textContainer] setContainerSize:NSMakeSize(size.width, FLT_MAX)];	
		[[_textView textContainer] setWidthTracksTextView:YES];
		NSRect frame = [_textView frame];
		frame.size.width = size.width;
		[_textView setFrame:frame];
	} else {
		// So we have horizontal scroll
		[[_textView enclosingScrollView] setHasHorizontalScroller:YES];		
		[_textView setHorizontallyResizable:YES];
		[[_textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];	
		[[_textView textContainer] setWidthTracksTextView:NO];		
	}
	[_textView setNeedsDisplay:YES];
}

- (IBAction)updateMode:(id)sender {
  GHUDebug(@"Update mode: %d", _segmentedControl.selectedSegment);
  switch(_segmentedControl.selectedSegment) {
    case 0: {
      dataSource_.editing = NO;
      [dataSource_.root setFilter:GHTestNodeFilterNone]; 
      break;
    }
    case 1: {
      dataSource_.editing = NO;
      [dataSource_.root setFilter:GHTestNodeFilterFailed]; 
      break;
    }
    case 2: {      
      dataSource_.editing = YES;      
      [dataSource_.root setFilter:GHTestNodeFilterNone];
      break;
    }
  }
  [dataSource_ saveDefaults];
  [self reload];
}

- (IBAction)updateSearchFilter:(id)sender {
  NSString *prefix = [_searchField stringValue];
  [dataSource_.root setTextFilter:prefix];
  [self _setPrefix:prefix];
  [self reload];
}

- (IBAction)copy:(id)sender {
	[_textView copy:sender];
}

- (IBAction)openExceptionFilename:(id)sender {
  if (self.exceptionFilename) {
    NSString *path = [self.exceptionFilename stringByExpandingTildeInPath];
    [[NSWorkspace sharedWorkspace] openFile:path];
  }
}

- (IBAction)rerunTest:(id)sender {
  id<GHTest> test = [[self selectedTest] copyWithZone:NULL];
  GHUDebug(@"Re-running: %@", test);
  [self _updateDetailForTest:nil prefix:@"Re-running test."];
  [test run:GHTestOptionForceSetUpTearDownClass];  
  [self _updateDetailForTest:test prefix:@"Re-ran test. (This feature is experimental.)"];  
}

- (BOOL)isShowingDetails {
  return ![[NSUserDefaults standardUserDefaults] boolForKey:@"ViewCollapsed"];
}

- (void)setShowingDetails:(BOOL)showingDetails {
  [[NSUserDefaults standardUserDefaults] setBool:(!showingDetails) forKey:@"ViewCollapsed"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReraiseExceptions:(BOOL)reraiseExceptions {
  [[NSUserDefaults standardUserDefaults] setBool:reraiseExceptions forKey:@"ReraiseExceptions"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)reraiseExceptions {
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"ReraiseExceptions"];  
}

- (void)setRunInParallel:(BOOL)runInParallel {
  [[NSUserDefaults standardUserDefaults] setBool:runInParallel forKey:@"RunInParallel"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)runInParallel {
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"RunInParallel"];  
}

- (void)hideDetails {
  [_detailsView removeFromSuperview];
  [_detailsToggleButton setState:NSOffState];
  [self setShowingDetails:NO];
}

- (void)showDetails {
  CGFloat windowWidth = self.view.window.frame.size.width;
  CGFloat minWindowWidth = MIN_WINDOW_WIDTH;
  if (windowWidth < minWindowWidth) {
    NSRect frame = self.view.window.frame;
    frame.size.width = minWindowWidth;
    [self.view.window setFrame:frame display:YES animate:YES];
  }
  [_splitView addSubview:_detailsView];
  [_detailsToggleButton setState:NSOnState];
  [self setShowingDetails:YES];
}

- (IBAction)toggleDetails:(id)sender {	
	if ([self isShowingDetails]) {
    [self hideDetails];
	} else {
    [self showDetails];
  }
}

- (void)loadDefaults {
	if (![self isShowingDetails]) {
    [self hideDetails];
	}
}

- (void)saveDefaults {
	[dataSource_ saveDefaults];
  [[NSUserDefaults standardUserDefaults] setInteger:_textSegmentedControl.selectedSegment forKey:@"TextSelectedSegment"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)_formatText:(NSString *)text {
	if (text) return [NSString stringWithFormat:@"%@\n", text]; // Newline important for when we append streaming text
  return @"";
}

- (NSString *)stackTraceForSelectedRow:(id<GHTest>)test {
  if (![test exception]) return @"";
  NSString *text = [GHTesting descriptionForException:[test exception]];
  return [self _formatText:text];
}

- (NSString *)logForSelectedRow:(id<GHTest>)test {
  NSString *text = [[test log] componentsJoinedByString:@"\n"]; // TODO(gabe): This isn't very performant
  return [self _formatText:text];
}

- (NSString *)textForSegment:(NSInteger)segment test:(id<GHTest>)test {
  if (!test) return @"";
  switch(segment) {
		case 0: return [self stackTraceForSelectedRow:test];
		case 1: return [self logForSelectedRow:test];
	}
  return nil;
}

- (void)_updateDetailForTest:(id<GHTest>)test prefix:(NSString *)prefix {
  NSMutableString *text = [NSMutableString string];
  if (prefix) [text appendFormat:@"\n\t%@\n\n", prefix];
  NSString *testDetail = [self textForSegment:[_textSegmentedControl selectedSegment] test:test];
  if (testDetail) [text appendString:testDetail];
  [_textView setString:text];
  self.exceptionFilename = [GHTesting exceptionFilenameForTest:test];  
  self.exceptionLineNumber = [GHTesting exceptionLineNumberForTest:test];
}

- (IBAction)updateTextSegment:(id)sender {
  [self _updateDetailForTest:[self selectedTest] prefix:nil];
}

- (GHTestNode *)selectedNode {
  NSInteger row = [_outlineView selectedRow];
	if (row < 0) return nil;
  return [_outlineView itemAtRow:row];  
}

- (id<GHTest>)selectedTest {
	return [self selectedNode].test;
}

- (void)selectFirstFailure {
	GHTestNode *failedNode = [dataSource_ findFailure];
	NSInteger row = [_outlineView rowForItem:failedNode];
	if (row >= 0) {		
    [self selectRow:row];
	}
}

- (void)selectRow:(NSInteger)row {
  if (row >= 0)
    [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
  
  [_textView setString:@""];
  
	[self updateTextSegment:_textSegmentedControl];
  
  self.exceptionFilename = [[self selectedNode] exceptionFilename];  
  self.exceptionLineNumber = [[self selectedNode] exceptionLineNumber];
  
}

- (void)_updateTest:(id<GHTest>)test {
	GHTestNode *testNode = [dataSource_ findTestNodeForTest:test];
	[_outlineView reloadItem:testNode];	

	NSInteger runCount = [suite_ stats].succeedCount + [suite_ stats].failureCount;
	NSInteger totalRunCount = [suite_ stats].testCount - ([suite_ disabledCount] + [suite_ stats].cancelCount);
	if (dataSource_.isRunning)
		self.statusProgress = ((double)runCount/(double)totalRunCount) * 100.0;
	self.status = [dataSource_ statusString:@"Status: "];
}

#pragma mark Delegates (GHTestOutlineViewModel)

- (void)testOutlineViewModelDidChangeSelection:(GHTestOutlineViewModel *)testOutlineViewModel {
  [self selectRow:-1];
}

#pragma mark Delegates (GHTestRunner)

- (void)testRunner:(GHTestRunner *)runner didLog:(NSString *)message {
	
}

- (void)testRunner:(GHTestRunner *)runner test:(id<GHTest>)test didLog:(NSString *)message {
	id<GHTest> selectedTest = self.selectedTest;
	if ([_textSegmentedControl selectedSegment] == 1 && [selectedTest isEqual:test]) {
		[_textView replaceCharactersInRange:NSMakeRange([[_textView string] length], 0) 
														 withString:[NSString stringWithFormat:@"%@\n", message]];
		// TODO(gabe): Scroll
	}	
}

- (void)testRunner:(GHTestRunner *)runner didStartTest:(id<GHTest>)test {
	[self _updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didUpdateTest:(id<GHTest>)test {
	[self _updateTest:test];
}

- (void)testRunner:(GHTestRunner *)runner didEndTest:(id<GHTest>)test {
	[self _updateTest:test];
  [self updateTextSegment:nil]; // In case test is selected before it ran
}

- (void)testRunnerDidStart:(GHTestRunner *)runner { 	
  self.running = YES;
	[self _updateTest:runner.test];  
}

- (void)testRunnerDidEnd:(GHTestRunner *)runner {
	GHUDebug(@"Test runner end: %@", [runner.test identifier]);
	[self _updateTest:runner.test];
	self.status = [dataSource_ statusString:@"Status: "];
	//[self selectFirstFailure];
  // TODO(gabe): This should be unnecessary
  self.statusProgress = 100.0;
	self.runLabel = @"Run";
  [dataSource_ saveDefaults];
  self.running = NO;
  
  if (getenv("GHUNIT_AUTOEXIT")) {
    NSLog(@"Exiting (GHUNIT_AUTOEXIT)");
    exit((int)runner.test.stats.failureCount);
    [NSApp terminate:self];
  }  
}

- (void)testRunnerDidCancel:(GHTestRunner *)runner {
	self.runLabel = @"Run";
	self.status = [dataSource_ statusString:@"Cancelled... "];
	self.statusProgress = 0;
  self.running = NO;
}

#pragma mark Delegates (NSSplitView)

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
  return 300;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex {
  return [self view].frame.size.width - 335;
}

@end
