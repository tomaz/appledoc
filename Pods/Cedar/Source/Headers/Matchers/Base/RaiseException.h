#import "Base.h"
#import <tr1/memory>

namespace Cedar { namespace Matchers {

    typedef void (^empty_block_t)();

    struct RaiseExceptionMessageBuilder {
        static NSString * string_for_actual_value(empty_block_t value) {
            return [value description];
        }
    };

    class RaiseException : public Base<RaiseExceptionMessageBuilder> {
    private:
        RaiseException & operator=(const RaiseException &);

    public:
        explicit RaiseException(NSObject * = nil, Class = nil, bool = false, NSString * = nil);
        ~RaiseException();
        // Allow default copy ctor.

        RaiseException operator()() const;
        RaiseException operator()(Class) const;
        RaiseException operator()(NSObject *) const;

        RaiseException & or_subclass();

        RaiseException & with_reason(NSString * const reason);
        RaiseException with_reason(NSString * const reason) const;

        bool matches(empty_block_t) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        bool exception_matches_expected_class(NSObject * const exception) const;
        bool exception_matches_expected_instance(NSObject * const exception) const;
        bool exception_matches_expected_reason(NSObject * const exception) const;

    private:
        const NSObject *expectedExceptionInstance_;
        const Class expectedExceptionClass_;
        bool allowSubclasses_;
        NSString *expectedReason_;
    };

    RaiseException raise() __attribute__((deprecated)); // Please use raise_exception
    RaiseException raise();

    static const RaiseException raise_exception;

}}
