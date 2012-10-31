#import "CDRFake.h"
#import "CDRClassFake.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

@interface CDRClassFake ()

@end

@implementation CDRClassFake

- (BOOL)respondsToSelector:(SEL)selector {
    return [self.klass instancesRespondToSelector:selector];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Fake implementation of %@ class", self.klass];
}

@end

id CDR_fake_for(Class klass, bool require_explicit_stubs /*= true*/) {
    return [[[CDRClassFake alloc] initWithClass:klass requireExplicitStubs:require_explicit_stubs] autorelease];
}
