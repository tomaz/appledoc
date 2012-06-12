#import "CDRExampleReporterViewController.h"
#import "CDRFunctions.h"
#import "CedarApplicationDelegate.h"
#import "CDRSpecStatusViewController.h"
#import "CDRDefaultReporter.h"
#import <objc/runtime.h>

@implementation CDRExampleReporterViewController

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    if (getenv("CEDAR_HEADLESS_SPECS")) {
        int exitStatus = runSpecsWithinUIApplication();
        exitWithStatusFromUIApplication(exitStatus);
    } else {
        [self performSelectorInBackground:@selector(startSpecs) withObject:NULL];
    }
}

- (void)viewDidUnload {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)startSpecs {
    runSpecsWithCustomExampleReporters([NSArray arrayWithObject:self]);
}

- (void)pushRootSpecStatusController:(NSArray *)groups {
    UIViewController *rootController = [[CDRSpecStatusViewController alloc] initWithExamples:groups];
    [self pushViewController:rootController animated:NO];
    [rootController release];
}

#pragma mark CDRExampleReporter
- (void)runWillStartWithGroups:(NSArray *)groups {
    // The specs run on a background thread, so callbacks from the runner will
    // arrive on that thread.  We need to push the event to the main thread in
    // order to update the UI.
    [self performSelectorOnMainThread:@selector(pushRootSpecStatusController:) withObject:groups waitUntilDone:NO];
}

- (void)runDidComplete {
}

- (int)result {
  return 0;
}

@end

