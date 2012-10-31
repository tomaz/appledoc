#import <vector>
#import "ValueArgument.h"

namespace Cedar { namespace Doubles {

    class InvocationMatcher {
    public:
        typedef std::vector<Argument::shared_ptr_t> arguments_vector_t;
        enum { OBJC_DEFAULT_ARGUMENT_COUNT = 2 };

    public:
        InvocationMatcher(const SEL);
        virtual ~InvocationMatcher() {}

        void add_argument(const Argument::shared_ptr_t argument);
        template<typename T>
        void add_argument(const T &);

        bool matches(NSInvocation * const) const;
        NSString *mismatch_reason();

        const SEL selector() const { return expectedSelector_; }
        const arguments_vector_t & arguments() const { return arguments_; }
        const bool match_any_arguments() const { return arguments_.empty(); }
        void verify_count_and_types_of_arguments(id instance) const;

    private:
        bool matches_arguments(NSInvocation * const) const;
        NSMethodSignature *method_signature_for_instance(id instance) const;
        void compare_argument_count_to_method_signature(NSMethodSignature * const methodSignature) const;
        void compare_argument_types_to_method_signature(NSMethodSignature * const methodSignature) const;

    private:
        const SEL expectedSelector_;
        arguments_vector_t arguments_;
    };

    template<typename T>
    void InvocationMatcher::add_argument(const T & value) {
        this->add_argument(Argument::shared_ptr_t(new ValueArgument<T>(value)));
    }

}}
