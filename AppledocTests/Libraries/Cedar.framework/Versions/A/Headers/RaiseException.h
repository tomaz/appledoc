#import "Base.h"

namespace Cedar { namespace Matchers {
    class RaiseException : public Base<> {
        typedef void (^empty_block_t)();

    private:
        RaiseException & operator=(const RaiseException &);

    public:
        explicit RaiseException(Class = nil, bool = false);
        ~RaiseException();
        // Allow default copy ctor.

        RaiseException & operator()(Class = nil);
        RaiseException operator()(Class = nil) const;

        RaiseException & or_subclass();
        RaiseException or_subclass() const;

        bool matches(empty_block_t) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const Class expectedExceptionClass_;
        bool allowSubclasses_;
    };

    RaiseException raise() __attribute__((deprecated)); // Please use raise_exception
    inline RaiseException raise() {
        return RaiseException();
    }

    static const RaiseException raise_exception = RaiseException();

    inline RaiseException::RaiseException(Class expectedExceptionClass /*= nil*/, bool allowSubclasses /*= false */)
    : Base<>(), expectedExceptionClass_(expectedExceptionClass), allowSubclasses_(allowSubclasses) {
    }

    inline RaiseException::~RaiseException() {
    }

    inline RaiseException & RaiseException::operator()(Class expectedExceptionClass /*= nil*/) {
        return *this;
    }

    inline RaiseException RaiseException::operator()(Class expectedExceptionClass /*= nil*/) const {
        return RaiseException(expectedExceptionClass);
    }

    inline RaiseException & RaiseException::or_subclass() {
        allowSubclasses_ = true;
        return *this;
    }

    inline RaiseException RaiseException::or_subclass() const {
        return RaiseException(expectedExceptionClass_, true);
    }

    inline bool RaiseException::matches(empty_block_t block) const {
        @try {
            block();
        }
        @catch (NSException *exception) {
            return !expectedExceptionClass_ || (allowSubclasses_ ? [exception isKindOfClass:expectedExceptionClass_] : [exception isMemberOfClass:expectedExceptionClass_]);
        }
        return false;
    }

    /*virtual*/ inline NSString * RaiseException::failure_message_end() const {
        NSMutableString *message = [NSMutableString stringWithFormat:@"raise an exception"];
        if (expectedExceptionClass_) {
            [message appendString:@" of class"];
            if (allowSubclasses_) {
                [message appendString:@", or subclass of class,"];
            }
            [message appendFormat:@" <%@>", NSStringFromClass(expectedExceptionClass_)];
        }
        return message;
    }
}}
