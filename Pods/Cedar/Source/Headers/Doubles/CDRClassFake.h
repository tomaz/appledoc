#import <Foundation/Foundation.h>
#import "CDRFake.h"
#import "CedarDouble.h"

@interface CDRClassFake : CDRFake

@end

id CDR_fake_for(Class klass, bool require_explicit_stubs = true);
