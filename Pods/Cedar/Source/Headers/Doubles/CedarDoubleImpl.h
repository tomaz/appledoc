#import <Foundation/Foundation.h>
#import "StubbedMethod.h"

@protocol CedarDouble;

@interface CedarDoubleImpl : NSObject

@property (nonatomic, retain, readonly) NSMutableArray *sent_messages;

- (id)initWithDouble:(NSObject<CedarDouble> *)parent_double;

- (void)reset_sent_messages;

- (Cedar::Doubles::StubbedMethod &)add_stub:(const Cedar::Doubles::StubbedMethod &)stubbed_method;
- (Cedar::Doubles::StubbedMethod::selector_map_t &)stubbed_methods;
- (BOOL)invoke_stubbed_method:(NSInvocation *)invocation;
- (void)record_method_invocation:(NSInvocation *)invocation;

@end
