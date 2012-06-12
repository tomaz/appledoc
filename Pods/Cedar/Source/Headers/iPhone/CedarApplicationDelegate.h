#import <UIKit/UIKit.h>

int runSpecsWithinUIApplication();
void exitWithStatusFromUIApplication(int status);

@class CDRExampleReporterViewController;

// In some cases CDRIPhoneOTestRunner needs to spin up an instance of Cedar app.
// It appears that SenTestingKit fails to start up the test when CedarApplicationDelegate
// is used. Solution is to use a subclass of UIApplicaton.
@interface CedarApplication : UIApplication {
    UIWindow *window_;
    CDRExampleReporterViewController *viewController_;
}
@end

// Needed for backwards compatibility with existing projects using CedarApplicationDelegate
@interface CedarApplicationDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window_;
    CDRExampleReporterViewController *viewController_;
}
@end
