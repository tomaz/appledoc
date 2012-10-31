#import "Base.h"

namespace Cedar { namespace Matchers {
    struct BeInstanceOfMessageBuilder {
        template<typename U>
        static NSString * string_for_actual_value(const U & value) {
            id idValue = value;
            return [NSString stringWithFormat:@"%@ (%@)", idValue, NSStringFromClass([idValue class])];
        }
    };

    class BeInstanceOf : public Base<BeInstanceOfMessageBuilder> {
    private:
        BeInstanceOf & operator=(const BeInstanceOf &);

    public:
        explicit BeInstanceOf(const Class expectedValue);
        ~BeInstanceOf();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        BeInstanceOf & or_any_subclass();

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const Class expectedClass_;
        bool includeSubclasses_;
    };

    inline BeInstanceOf be_instance_of(const Class expectedValue) {
        return BeInstanceOf(expectedValue);
    }

    inline BeInstanceOf::BeInstanceOf(const Class expectedClass)
    : Base<BeInstanceOfMessageBuilder>(), expectedClass_(expectedClass), includeSubclasses_(false) {}

    inline BeInstanceOf::~BeInstanceOf() {}

    inline BeInstanceOf & BeInstanceOf::or_any_subclass() {
        includeSubclasses_ = true;
        return *this;
    }

    inline /*virtual*/ NSString * BeInstanceOf::failure_message_end() const {
        NSMutableString *messageEnd = [NSMutableString stringWithFormat:@"be an instance of class <%@>", expectedClass_];
        if (includeSubclasses_) {
            [messageEnd appendString:@", or any of its subclasses"];
        }
        return messageEnd;
    }

#pragma mark Generic
    template<typename U>
    bool BeInstanceOf::matches(const U & actualValue) const {
        if (includeSubclasses_) {
            return [actualValue isKindOfClass:expectedClass_];
        } else {
            return [actualValue isMemberOfClass:expectedClass_];
        }
    }
}}
