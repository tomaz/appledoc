#import "ActualValue.h"

namespace Cedar { namespace Matchers {

    struct ActualValueMarker {
        const char *fileName;
        int lineNumber;
    };

    template<typename T>
    const ActualValue<T> operator,(const T & actualValue, const ActualValueMarker & marker) {
        return ActualValue<T>(marker.fileName, marker.lineNumber, actualValue);
    }

    template<typename T>
    const ActualValueMatchProxy<T> operator,(const ActualValue<T> & actualValue, bool negate) {
        return negate ? actualValue.to_not : actualValue.to;
    }

    template<typename T, typename MatcherType>
    void operator,(const ActualValueMatchProxy<T> & matchProxy, const MatcherType & matcher) {
        matchProxy(matcher);
    }

}}

#ifndef CEDAR_MATCHERS_DISALLOW_SHOULD
    #define should ,(ActualValueMarker){__FILE__, __LINE__},false,
    #define should_not ,(ActualValueMarker){__FILE__, __LINE__},true,
#endif
