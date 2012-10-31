#import <Foundation/Foundation.h>

namespace Cedar { namespace Doubles {
    class StubbedMethod;
}}

@protocol CedarDouble<NSObject>

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method;
- (NSArray *)sent_messages;
- (void)reset_sent_messages;

@end

namespace Cedar { namespace Doubles {

    struct MethodStubbingMarker {
        const char *fileName;
        int lineNumber;
    };

    id<CedarDouble> operator,(id, const MethodStubbingMarker &);

    void operator,(id<CedarDouble>, const StubbedMethod &);
}}

#ifndef CEDAR_MATCHERS_DISALLOW_STUB_METHOD
#define stub_method(x) ,(Cedar::Doubles::MethodStubbingMarker){__FILE__, __LINE__},Cedar::Doubles::StubbedMethod((x))
#endif
