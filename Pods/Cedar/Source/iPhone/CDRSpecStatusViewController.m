#import "CDRSpecStatusViewController.h"
#import "CDRExampleGroup.h"
#import "CDRSpecStatusCell.h"
#import "CDRExampleDetailsViewController.h"

@interface CDRSpecStatusViewController (Private)
- (void)pushStatusViewForExamples:(NSArray *)examples;
@end

@implementation CDRSpecStatusViewController

#pragma mark -
#pragma mark Initialization
- (id)initWithExamples:(NSArray *)examples {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        examples_ = [examples retain];
    }
    return self;
}

- (void)dealloc {
    [examples_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the text of the label in the middle of the navigation bar to the test target's bundle
    // display name, which Xcode defaults to ${PRODUCT_NAME}, i.e., whatever you enter for "Product
    // Name," e.g., "Spec," when creating a new target. You can later change the "Product Name" from
    // the target's Build Settings.
    self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [examples_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CedarExampleCell";

    id cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[CDRSpecStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    [cell setExample:[examples_ objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedExample = [examples_ objectAtIndex:indexPath.row];
    if ([selectedExample hasChildren]) {
        [self pushStatusViewForExamples:[selectedExample examples]];
    } else {
        CDRExampleDetailsViewController * exampleDetailsController = [[CDRExampleDetailsViewController alloc] initWithExample:selectedExample];
        exampleDetailsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:exampleDetailsController animated:YES];
        [exampleDetailsController release];
    }
}

// This method sets the background color explicitly, because in the render cycle
// for cells this is where the cell controls its background color (as opposed to
// the table controlling the background color, as when the selection color
// changes).  See http://stackoverflow.com/questions/281515
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(id)cell setBackgroundColorToStatusColor];
}

#pragma mark Private interface
- (void)pushStatusViewForExamples:(NSArray *)examples {
    UIViewController *subController = [[CDRSpecStatusViewController alloc] initWithExamples:examples];
    [self.navigationController pushViewController:subController animated:YES];
    [subController release];
}

@end

