#import "CDRSpec.h"
#import "CDRExample.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"
#import "SpecHelper.h"

CDRSpec *currentSpec;

void beforeEach(CDRSpecBlock block) {
    [currentSpec.currentGroup addBefore:block];
}

void afterEach(CDRSpecBlock block) {
    [currentSpec.currentGroup addAfter:block];
}

CDRExampleGroup * describe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *parentGroup = currentSpec.currentGroup;

    CDRExampleGroup *group = [CDRExampleGroup groupWithText:text];
    [parentGroup add:group];

    if (block) {
        currentSpec.currentGroup = group;
        block();
        currentSpec.currentGroup = parentGroup;
    }
    return group;
}

CDRExampleGroup * context(NSString *text, CDRSpecBlock block) {
    return describe(text, block);
}

CDRExample * it(NSString *text, CDRSpecBlock block) {
    CDRExample *example = [CDRExample exampleWithText:text andBlock:block];
    [currentSpec.currentGroup add:example];
    return example;
}

CDRExampleGroup * xdescribe(NSString *text, CDRSpecBlock block) {
    return describe(text, ^{});
}

CDRExampleGroup * xcontext(NSString *text, CDRSpecBlock block) {
    return xdescribe(text, block);
}

CDRExample * xit(NSString *text, CDRSpecBlock block) {
    return it(text, PENDING);
}

CDRExampleGroup * fdescribe(NSString *text, CDRSpecBlock block) {
    CDRExampleGroup *group = describe(text, block);
    group.focused = YES;
    return group;
}

CDRExampleGroup * fcontext(NSString *text, CDRSpecBlock block) {
    return fdescribe(text, block);
}

CDRExample * fit(NSString *text, CDRSpecBlock block) {
    CDRExample *example = it(text, block);
    example.focused = YES;
    return example;
}

void fail(NSString *reason) {
    [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Failure: %@", reason]] raise];
}

@implementation CDRSpec

@synthesize currentGroup = currentGroup_, rootGroup = rootGroup_;

#pragma mark Memory
- (id)init {
    if (self = [super init]) {
        self.rootGroup = [[[CDRExampleGroup alloc] initWithText:[[self class] description] isRoot:YES] autorelease];
        self.rootGroup.parent = [SpecHelper specHelper];
        self.currentGroup = self.rootGroup;
    }
    return self;
}

- (void)dealloc {
    self.rootGroup = nil;
    self.currentGroup = nil;

    [super dealloc];
}

- (void)defineBehaviors {
    currentSpec = self;
    [self declareBehaviors];
    currentSpec = nil;
}

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
