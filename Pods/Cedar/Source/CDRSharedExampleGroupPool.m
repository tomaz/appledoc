#import "CDRSharedExampleGroupPool.h"
#import "SpecHelper.h"
#import "CDRSpec.h"
#import "CDRExampleGroup.h"
#import "CDRSpecFailure.h"

extern CDRSpec *currentSpec;

@interface SpecHelper (CDRSharedExampleGroupPoolFriend)
@property (nonatomic, retain, readonly) NSMutableDictionary *sharedExampleGroups;
@end

void sharedExamplesFor(NSString *groupName, CDRSharedExampleGroupBlock block) {
    [[[SpecHelper specHelper] sharedExampleGroups] setObject:[[block copy] autorelease] forKey:groupName];
}

void itShouldBehaveLike(NSString *groupName) {
    CDRSharedExampleGroupBlock sharedExampleGroupBlock = [[[SpecHelper specHelper] sharedExampleGroups] objectForKey:groupName];
    if (!sharedExampleGroupBlock) {
        NSString *message = [NSString stringWithFormat:@"Unknown shared example group with description: '%@'", groupName];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:message userInfo:nil] raise];
    }

    CDRExampleGroup *parentGroup = currentSpec.currentGroup;
    currentSpec.currentGroup = [CDRExampleGroup groupWithText:[NSString stringWithFormat:@"(as %@)", groupName]];
    [parentGroup add:currentSpec.currentGroup];

    sharedExampleGroupBlock([SpecHelper specHelper].sharedExampleContext);
    currentSpec.currentGroup = parentGroup;
}

@implementation CDRSharedExampleGroupPool

- (void)failWithException:(NSException *)exception {
    [[CDRSpecFailure specFailureWithReason:[exception reason]] raise];
}

@end
