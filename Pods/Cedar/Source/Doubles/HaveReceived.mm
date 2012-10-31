#import "HaveReceived.h"
#import "CedarDouble.h"

namespace Cedar { namespace Doubles {

    HaveReceived::HaveReceived(const SEL expectedSelector)
    : Base<>(), InvocationMatcher(expectedSelector) {
    }

    HaveReceived::~HaveReceived() {
    }

    bool HaveReceived::matches(id instance) const {
        this->verify_object_is_a_double(instance);
        this->verify_count_and_types_of_arguments(instance);

        for (NSInvocation *invocation in [instance sent_messages]) {
            if (this->InvocationMatcher::matches(invocation)) {
                return true;
            }
        }
        return false;
    }

    void HaveReceived::verify_object_is_a_double(id instance) const {
        if (![[instance class] conformsToProtocol:@protocol(CedarDouble)]) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]
                                   userInfo:nil]
             raise];
        }
    }

#pragma mark - Protected interface
    /*virtual*/ NSString * HaveReceived::failure_message_end() const {
        NSString * selectorString = NSStringFromSelector(this->selector());
        NSMutableString *message = [NSMutableString stringWithFormat:@"have received message <%@>", selectorString];
        if (this->arguments().size()) {
            [message appendString:@", with arguments: <"];
            arguments_vector_t::const_iterator cit = this->arguments().begin();
            [message appendString:(*cit++)->value_string()];
            for (; cit != this->arguments().end(); ++cit) {
                [message appendString:[NSString stringWithFormat:@", %@", (*cit)->value_string()]];
            }
            [message appendString:@">"];
        }
        return message;
    }


#pragma mark -
    HaveReceived have_received(const SEL expectedSelector) {
        return HaveReceived(expectedSelector);
    }

    HaveReceived have_received(const char * expectedMethod) {
        return HaveReceived(NSSelectorFromString([NSString stringWithUTF8String:expectedMethod]));
    }

}}
