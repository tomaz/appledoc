#import "CedarDouble.h"
#import "CDRSpy.h"
#import "StubbedMethod.h"

namespace Cedar { namespace Doubles {

    id<CedarDouble> operator,(id instance, const MethodStubbingMarker & marker) {
        if (![[instance class] conformsToProtocol:@protocol(CedarDouble)]) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"%@ is not a double", instance]
                                   userInfo:nil]
             raise];
        }
        return instance;
    }

    void operator,(id<CedarDouble> double_instance, const StubbedMethod & stubbed_method) {
        return [double_instance add_stub:stubbed_method];
    }

}}
