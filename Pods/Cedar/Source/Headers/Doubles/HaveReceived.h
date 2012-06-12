#import "Base.h"
#import "Argument.h"
#import "objc/runtime.h"

namespace Cedar { namespace Doubles {
    class HaveReceived : public Matchers::Base<> {
    private:
        HaveReceived & operator=(const HaveReceived &);

    public:
        explicit HaveReceived(const SEL);
        ~HaveReceived();
        // Allow default copy ctor.

        template<typename T>
        HaveReceived & with(const T &);
        template<typename T>
        HaveReceived & and_with(const T & argument) { return with(argument); }

        bool matches(id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void verify_object_is_a_double(id) const;
        bool matches_invocation(NSInvocation * const) const;
        bool matches_arguments(NSInvocation * const) const;
        void verify_correct_number_of_arguments(NSInvocation * const) const;

    private:
        const SEL expectedSelector_;

        typedef std::vector<Argument *> arguments_vector_t;
        arguments_vector_t arguments_;
    };

    HaveReceived have_received(const SEL expectedSelector);
    HaveReceived have_received(const char * expectedMethod);

    template<typename T>
    HaveReceived & HaveReceived::with(const T & value) {
        Argument *arg = new TypedArgument<T>(value);

        arguments_.push_back(arg);
        return *this;
    }

    // This belongs in a separate implementation file, but doing so generates an
    // inscrutable linker error:
    //
    // ld: bad codegen, pointer diff in ___block_global_9 to global weak symbol
    // __ZTVN5Cedar8Matchers4BaseINS0_18BaseMessageBuilderEEE for architecture i386
#pragma mark Implementation

    inline HaveReceived have_received(const SEL expectedSelector) {
        return HaveReceived(expectedSelector);
    }

    inline HaveReceived have_received(const char * expectedMethod) {
        return HaveReceived(NSSelectorFromString([NSString stringWithUTF8String:expectedMethod]));
    }

    inline HaveReceived::HaveReceived(const SEL expectedSelector)
    : Base<>(), expectedSelector_(expectedSelector) {
    }

    inline HaveReceived::~HaveReceived() {
        for (arguments_vector_t::const_iterator cit = arguments_.begin(); cit != arguments_.end(); ++cit) {
            delete *cit;
        }
        arguments_.clear();
    }

    inline bool HaveReceived::matches(id instance) const {
        this->verify_object_is_a_double(instance);

        for (NSInvocation *invocation in [instance sent_messages]) {
            if (this->matches_invocation(invocation)) {
                return true;
            }
        }
        return false;
    }

    inline void HaveReceived::verify_object_is_a_double(id instance) const {
        if (![instance respondsToSelector:@selector(sent_messages)]) {
            [[CDRSpecFailure specFailureWithReason:[NSString stringWithFormat:@"Received expectation for non-double object <%@>", instance]] raise];
        }
    }

#pragma mark Protected interface
    inline /*virtual*/ NSString * HaveReceived::failure_message_end() const {
        NSMutableString *message = [NSMutableString stringWithFormat:@"have received message <%@>", NSStringFromSelector(expectedSelector_)];
        if (arguments_.size()) {
            [message appendString:@", with arguments: <"];
            arguments_vector_t::const_iterator cit = arguments_.begin();
            [message appendString:(*cit++)->value_string()];
            for (; cit != arguments_.end(); ++cit) {
                [message appendString:[NSString stringWithFormat:@", %@", (*cit)->value_string()]];
            }
            [message appendString:@">"];
        }
        return message;
    }

#pragma mark Private interface
    inline bool HaveReceived::matches_invocation(NSInvocation * const invocation) const {
        return sel_isEqual(invocation.selector, expectedSelector_) && this->matches_arguments(invocation);
    }

    inline bool HaveReceived::matches_arguments(NSInvocation * const invocation) const {
        this->verify_correct_number_of_arguments(invocation);

        bool matches = true;
        size_t index = 2;
        for (arguments_vector_t::const_iterator cit = arguments_.begin(); cit != arguments_.end() && matches; ++cit, ++index) {
            const char *actualArgumentEncoding = [invocation.methodSignature getArgumentTypeAtIndex:index];
            NSUInteger actualArgumentSize;
            NSGetSizeAndAlignment(actualArgumentEncoding, &actualArgumentSize, nil);

            char actualArgumentBytes[actualArgumentSize];
            [invocation getArgument:&actualArgumentBytes atIndex:index];
            matches = (*cit)->matches_bytes(&actualArgumentBytes);
        }
        return matches;
    }

    inline void HaveReceived::verify_correct_number_of_arguments(NSInvocation * const invocation) const {
        size_t expectedArgumentCount = arguments_.size();
        size_t actualArgumentCount = invocation.methodSignature.numberOfArguments - 2; //

        if (expectedArgumentCount) {
            if (expectedArgumentCount < actualArgumentCount) {
                NSString *reason = [NSString stringWithFormat:@"Too few parameters expected for message <%@>; required %d, expected %d", NSStringFromSelector(expectedSelector_), actualArgumentCount, expectedArgumentCount];
                [[CDRSpecFailure specFailureWithReason:reason] raise];
            } else if (expectedArgumentCount > actualArgumentCount) {
                NSString *reason = [NSString stringWithFormat:@"Too many parameters expected for message <%@>; required %d, expected %d", NSStringFromSelector(expectedSelector_), actualArgumentCount, expectedArgumentCount];
                [[CDRSpecFailure specFailureWithReason:reason] raise];
            }
        }
    }

}}
