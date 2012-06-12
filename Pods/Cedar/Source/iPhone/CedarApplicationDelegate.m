#import "CedarApplicationDelegate.h"
#import "CDRExampleReporterViewController.h"
#import "CDRFunctions.h"
#import <objc/runtime.h>

int runSpecsWithinUIApplication() {
    int exitStatus;

    char *defaultReporterClassName = objc_getClass("SenTestProbe") ? "CDROTestReporter" : "CDRDefaultReporter";
    NSArray *reporters = CDRReportersFromEnv(defaultReporterClassName);

    if (![reporters count]) {
        exitStatus = -999;
    } else {
        exitStatus = runSpecsWithCustomExampleReporters(reporters);
    }

    return exitStatus;
}

void exitWithStatusFromUIApplication(int status) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(_terminateWithStatus:)]) {
        [application performSelector:@selector(_terminateWithStatus:) withObject:(id)status];
    } else {
        exit(status);
    }
}

@implementation CedarApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    viewController_ = [[CDRExampleReporterViewController alloc] init];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

    return NO;
}

@end

@implementation CedarApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    viewController_ = [[CDRExampleReporterViewController alloc] init];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];

    return NO;
}

@end
