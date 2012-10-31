#import "CDRSpy.h"
#import "objc/runtime.h"
#import "StubbedMethod.h"
#import "CedarDoubleImpl.h"

@implementation CDRSpy

+ (void)interceptMessagesForInstance:(id)instance {
    Class originalClass = [instance class];
    objc_setAssociatedObject(instance, @"original-class", originalClass, OBJC_ASSOCIATION_ASSIGN);

    CedarDoubleImpl *cedar_double_impl = [[[CedarDoubleImpl alloc] initWithDouble:instance] autorelease];
    objc_setAssociatedObject(instance, @"cedar-double-implementation", cedar_double_impl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    object_setClass(instance, self);
}

- (void)dealloc {
    object_setClass(self, objc_getAssociatedObject(self, @"original-class"));

    [self dealloc];

    // DO NOT call the destructor on super, since the superclass has already
    // destroyed itself when the original class's destructor called [super dealloc].
    // This (no-op) line must be here to prevent the compiler from helpfully
    // generating an error that the method has no [super dealloc] call.
    if(0) { [super dealloc]; }
}

- (NSString *)description {
    __block NSString *description;
    [self as_original_class:^{
        description = [self description];
    }];

    return description;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self.cedar_double_impl record_method_invocation:invocation];

    if (![self.cedar_double_impl invoke_stubbed_method:invocation]) {
/* This *almost* works, but makes KVC and some UIKit classes unhappy. */
//        [self as_class:[self createTransientClassForSelector:invocation.selector] :^{
        [self as_original_class:^{
            [invocation invoke];
        }];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    __block NSMethodSignature *originalMethodSignature;

    [self as_original_class:^{
        originalMethodSignature = [self methodSignatureForSelector:sel];
    }];

    return originalMethodSignature;
}

- (BOOL)respondsToSelector:(SEL)selector {
    __block BOOL respondsToSelector;

    [self as_original_class:^{
        respondsToSelector = [self respondsToSelector:selector];
    }];

    return respondsToSelector;
}

#pragma mark - CedarDouble protocol

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method {
    return [self.cedar_double_impl add_stub:stubbed_method];
}

- (NSArray *)sent_messages {
    return self.cedar_double_impl.sent_messages;
}

- (void)reset_sent_messages {
    return self.cedar_double_impl.reset_sent_messages;
}

#pragma mark - Private interface

- (CedarDoubleImpl *)cedar_double_impl {
    return objc_getAssociatedObject(self, @"cedar-double-implementation");
}

- (void)as_class:(Class)klass :(void(^)())block {
    block = [[block copy] autorelease];

    Class spyClass = object_getClass(self);
    object_setClass(self, klass);

    @try {
        block();
    } @finally {
        object_setClass(self, spyClass);
    }
}

- (void)as_original_class:(void(^)())block {
    [self as_class:objc_getAssociatedObject(self, @"original-class") :block];
}

- (Class)createTransientClassForSelector:(SEL)selector {
    Class klass = objc_allocateClassPair([CDRSpy class], [self.uniqueClassName cStringUsingEncoding:NSUTF8StringEncoding], 0);
    objc_registerClassPair(klass);

    Class originalClass = objc_getAssociatedObject(self, @"original-class");
    Method originalMethod = class_getInstanceMethod(originalClass, selector);

    /*
     Every now and then a method returns NULL for its implementation.  Since I have no
     idea why, or how to get around this in a generic way, fall back to the original
     class itself.  This will cause the spy to not record subsequent methods invoked
     on self, but hopefully this is rare enough to not cause a problem.

     The alternative is an EXC_BAD_ACCESS.
     */
    if (!originalMethod) {
        return originalClass;
    }

    class_addMethod(klass, selector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    return klass;
}

- (NSString *)uniqueClassName {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid) autorelease];
    CFRelease(uuid);

    return [NSString stringWithFormat:@"CDRSpyTransientClass-%@", uuidStr];
}

@end
