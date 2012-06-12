#import <UIKit/UIKit.h>

@class CDRExampleBase;

@interface CDRExampleDetailsViewController : UIViewController

@property (nonatomic, assign) UINavigationBar *navigationBar;
@property (nonatomic, assign) UILabel *fullTextLabel, *messageLabel;

- (id)initWithExample:(CDRExampleBase *)example;

@end
