#import <Foundation/Foundation.h>
#import "CedarDouble.h"

@interface CDRSpy : NSProxy<CedarDouble>

+ (void)interceptMessagesForInstance:(id)instance;

@end

namespace Cedar { namespace Doubles {
    inline void CDR_spy_on(id instance) {
        if (![[instance class] conformsToProtocol:@protocol(CedarDouble)]) {
            [CDRSpy interceptMessagesForInstance:instance];
        }
    }
}}

#ifndef CEDAR_DOUBLES_COMPATIBILITY_MODE
#define spy_on(x) CDR_spy_on((x))
#endif
