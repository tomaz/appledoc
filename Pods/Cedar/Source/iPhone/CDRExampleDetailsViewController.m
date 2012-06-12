#import "CDRExampleDetailsViewController.h"
#import "CDRExampleBase.h"
#import "CDRExampleStateMap.h"

@interface CDRExampleDetailsViewController ()

@property (nonatomic, retain) CDRExampleBase *example;

- (UINavigationBar *)addNavigationBar;
- (CGRect)navigationBarFrame;
- (UILabel *)addLabelWithText:(NSString *)text;
- (void)positionAndSizeLabels;
- (void)minimizeFrameRectForLabel:(UILabel *)label withTop:(float)top andBottom:(float)bottom;
@end

static const float TEXT_LABEL_MARGIN = 20.0;

@implementation CDRExampleDetailsViewController

@synthesize navigationBar = navigationBar_, fullTextLabel = fullTextLabel_, messageLabel = messageLabel_, example = example_;

- (id)initWithExample:(CDRExampleBase *)example {
    if ((self = [super init])) {
        self.example = example;
    }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    [example_ release];
    [super dealloc];
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationBar = [self addNavigationBar];
    self.fullTextLabel = [self addLabelWithText:[(id)self.example fullText]];
    self.messageLabel = [self addLabelWithText:[self.example message]];
    [self positionAndSizeLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationBar.frame = [self navigationBarFrame];
    [self positionAndSizeLabels];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.navigationBar.frame = [self navigationBarFrame];
    [self positionAndSizeLabels];
}

#pragma mark Target actions
- (void)closeWindow {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark Private interface
- (UINavigationBar *)addNavigationBar {
    UINavigationBar *navigationBar = [[[UINavigationBar alloc] initWithFrame:[self navigationBarFrame]] autorelease];
    [self.view addSubview:navigationBar];

    NSString *stateName = [[CDRExampleStateMap stateMap] descriptionForState:self.example.state];
    UINavigationItem *navigationItem = [[[UINavigationItem alloc] initWithTitle:stateName] autorelease];
    [navigationBar pushNavigationItem:navigationItem animated:NO];

    UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeWindow)] autorelease];
    navigationItem.rightBarButtonItem = closeButton;

    return navigationBar;
}

- (CGRect)navigationBarFrame {
    return CGRectMake(0, 0, self.view.bounds.size.width, 44);
}

- (UILabel *)addLabelWithText:(NSString *)text {
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
    label.numberOfLines = 0;
    label.text = text;
    [self.view addSubview:label];

    return label;
}

- (void)positionAndSizeLabels {
    [self minimizeFrameRectForLabel:self.fullTextLabel withTop:self.navigationBar.bounds.size.height andBottom:self.view.bounds.size.height / 2];
    [self minimizeFrameRectForLabel:self.messageLabel withTop:self.fullTextLabel.frame.origin.y + self.fullTextLabel.frame.size.height andBottom:self.view.bounds.size.height];
}

- (void)minimizeFrameRectForLabel:(UILabel *)label withTop:(float)top andBottom:(float)bottom {
    CGRect maximumFrameRect = CGRectMake(TEXT_LABEL_MARGIN, TEXT_LABEL_MARGIN + top, self.view.bounds.size.width - TEXT_LABEL_MARGIN * 2, bottom - top - TEXT_LABEL_MARGIN * 2);
    label.frame = maximumFrameRect;

    CGRect minimumRect = [label textRectForBounds:[label bounds] limitedToNumberOfLines:[label numberOfLines]];
    minimumRect.origin = label.frame.origin;
    label.frame = minimumRect;
}

@end
