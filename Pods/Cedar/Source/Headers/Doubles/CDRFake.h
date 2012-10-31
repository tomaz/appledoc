#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRFake : NSObject<CedarDouble>

@property (nonatomic, assign) Class klass;

- (id)initWithClass:(Class)klass requireExplicitStubs:(bool)requireExplicitStubs;

@end

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define fake_for(x) CDR_fake_for((x))
#define nice_fake_for(x) CDR_fake_for((x), false)
#endif
