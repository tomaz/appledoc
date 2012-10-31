#import <Foundation/Foundation.h>
#import <tr1/memory>
#import <vector>
#import "InvocationMatcher.h"
#import "Argument.h"
#import "ReturnValue.h"

namespace Cedar { namespace Doubles {

    class StubbedMethod : private InvocationMatcher {
    private:
        typedef void (^invocation_block_t)(NSInvocation *);

    private:
        StubbedMethod & operator=(const StubbedMethod &);

    public:
        StubbedMethod(SEL);
        StubbedMethod(const char *);
        StubbedMethod(const StubbedMethod &);
        virtual ~StubbedMethod();

        template<typename T>
        StubbedMethod & and_return(const T &);
        StubbedMethod & and_do(invocation_block_t);

        StubbedMethod & with(const Argument::shared_ptr_t argument);
        StubbedMethod & and_with(const Argument::shared_ptr_t argument);

        template<typename T>
        StubbedMethod & with(const T &);
        template<typename T>
        StubbedMethod & and_with(const T &);

        StubbedMethod & and_raise_exception();
        StubbedMethod & and_raise_exception(NSObject * exception);

        Argument & return_value() const { return *return_value_argument_; };

        struct SelCompare {
            bool operator() (const SEL& lhs, const SEL& rhs) const {
                return strcmp(sel_getName(lhs), sel_getName(rhs)) < 0;
            }
        };
        typedef std::tr1::shared_ptr<StubbedMethod> shared_ptr_t;
        typedef std::map<SEL, shared_ptr_t, SelCompare> selector_map_t;

        const SEL selector() const;
        bool matches(NSInvocation * const invocation) const;
        bool invoke(NSInvocation * invocation) const;
        void validate_against_instance(id instance) const;

    private:
        bool has_return_value() const { return return_value_argument_.get(); };
        bool has_invocation_block() const { return invocation_block_; }

    private:
        Argument::shared_ptr_t return_value_argument_;
        invocation_block_t invocation_block_;
        NSObject * exception_to_raise_;
    };

    template<typename T>
    StubbedMethod & StubbedMethod::and_return(const T & return_value) {
        if (this->has_invocation_block()) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Multiple return values specified for <%@>", selectorString]
                                   userInfo:nil] raise];
        }

        return_value_argument_ = Argument::shared_ptr_t(new ReturnValue<T>(return_value));
        return *this;
    }

    template<typename T>
    StubbedMethod & StubbedMethod::with(const T & argument) {
        return with(Argument::shared_ptr_t(new ValueArgument<T>(argument)));
    }

    template<typename T>
    StubbedMethod & StubbedMethod::and_with(const T & argument) {
        return with(argument);
    }

}}
