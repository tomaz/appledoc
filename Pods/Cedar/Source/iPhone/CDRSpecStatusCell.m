#import "CDRSpecStatusCell.h"
#import "CDRExampleBase.h"
#import "CDRExampleStateMap.h"

@interface CDRSpecStatusCell (Private)
- (void)setUpDisplayForExample:(CDRExampleBase *)example;
- (UIColor *)colorForStatus;
@end

@implementation CDRSpecStatusCell

@synthesize example = example_;

- (void)dealloc {
    self.example = nil;
    [super dealloc];
}

- (void)setExample:(CDRExampleBase *)example {
    if (example_ != example) {
        [example_ release];
        example_ = [example retain];

        [self setUpDisplayForExample:example];
        [example_ addObserver:self forKeyPath:@"state" options:0 context:NULL];
    }
}

- (void)setBackgroundColorToStatusColor {
    self.backgroundColor = [self colorForStatus];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self performSelectorOnMainThread:@selector(redrawCell) withObject:NULL waitUntilDone:NO];
}

#pragma mark Private interface
- (void)setUpDisplayForExample:(CDRExampleBase *)example {
    self.textLabel.text = example.text;
    self.detailTextLabel.text = [[CDRExampleStateMap stateMap] descriptionForState:self.example.state];
    if ([example_ hasChildren]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)redrawCell {
    self.backgroundColor = [self colorForStatus];
    self.detailTextLabel.text = [[CDRExampleStateMap stateMap] descriptionForState:self.example.state];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (UIColor *)colorForStatus {
    switch ([self.example state]) {
        case CDRExampleStatePassed:
            return [UIColor greenColor];
        case CDRExampleStatePending:
            return [UIColor yellowColor];
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            return [UIColor redColor];
        default:
            return [UIColor whiteColor];
    }
}

@end
