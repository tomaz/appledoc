#import <UIKit/UIKit.h>

@class CDRExampleBase;

@interface CDRSpecStatusCell : UITableViewCell {
    CDRExampleBase *example_;
}

@property (nonatomic, retain) CDRExampleBase *example;

- (void)setBackgroundColorToStatusColor;
@end
