#import <Foundation/Foundation.h>
#import <sstream>

#import "CedarStringifiers.h"

namespace Cedar { namespace Matchers {
    struct BaseMessageBuilder {
        template<typename U>
        static NSString * string_for_actual_value(const U & value) {
            return Stringifiers::string_for(value);
        }
    };

    /**
     * Basic functionality for all matchers.  Meant to be used as a convenience base class for
     * matcher classes.
     */
    template<typename MessageBuilder_ = BaseMessageBuilder>
    class Base {
    private:
        Base & operator=(const Base &);

    public:
        Base();
        virtual ~Base() = 0;
        // Allow default copy ctor.

        template<typename U>
        NSString * failure_message_for(const U &) const;
        template<typename U>
        NSString * negative_failure_message_for(const U &) const;

    protected:
        virtual NSString * failure_message_end() const = 0;
    };

    template<typename MessageBuilder_>
    Base<MessageBuilder_>::Base() {}
    template<typename MessageBuilder_>
    Base<MessageBuilder_>::~Base() {}

    template<typename MessageBuilder_> template<typename U>
    NSString * Base<MessageBuilder_>::failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->failure_message_end();
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to %@", actualValueString, failureMessageEnd];
    }

    template<typename MessageBuilder_> template<typename U>
    NSString * Base<MessageBuilder_>::negative_failure_message_for(const U & value) const {
        NSString * failureMessageEnd = this->failure_message_end();
        NSString * actualValueString = MessageBuilder_::string_for_actual_value(value);
        return [NSString stringWithFormat:@"Expected <%@> to not %@", actualValueString, failureMessageEnd];
    }
}}
