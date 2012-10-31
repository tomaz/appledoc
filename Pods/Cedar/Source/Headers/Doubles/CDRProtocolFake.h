#import <Foundation/Foundation.h>
#import "CedarDouble.h"
#import "CDRFake.h"
#import "objc/runtime.h"

#import <sstream>
#import <string>

@interface CDRProtocolFake : CDRFake

- (id)initWithClass:(Class)klass forProtocol:(Protocol *)protocol requireExplicitStubs:(bool)requireExplicitStubs;

@end

id CDR_fake_for(Protocol *protocol, bool require_explicit_stubs = true);
