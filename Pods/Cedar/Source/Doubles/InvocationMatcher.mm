#import "InvocationMatcher.h"
#import <objc/runtime.h>

namespace Cedar { namespace Doubles {

    InvocationMatcher::InvocationMatcher(const SEL selector) :
    expectedSelector_(selector) {
    }

    void InvocationMatcher::add_argument(const Argument::shared_ptr_t argument) {
        arguments_.push_back(argument);
    }

    bool InvocationMatcher::matches(NSInvocation * const invocation) const {
        return sel_isEqual(invocation.selector, selector()) && this->matches_arguments(invocation);
    }

    void InvocationMatcher::verify_count_and_types_of_arguments(id instance) const {
        if (this->match_any_arguments()) {
            return;
        }

        NSMethodSignature *methodSignature = this->method_signature_for_instance(instance);
        this->compare_argument_count_to_method_signature(methodSignature);
        this->compare_argument_types_to_method_signature(methodSignature);
    }

#pragma mark - Private interface

    bool InvocationMatcher::matches_arguments(NSInvocation * const invocation) const {
        bool matches = true;
        size_t index = OBJC_DEFAULT_ARGUMENT_COUNT;
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

    NSMethodSignature *InvocationMatcher::method_signature_for_instance(id instance) const {
        NSMethodSignature *methodSignature = [instance methodSignatureForSelector:this->selector()];
        if (!methodSignature) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Received expectation on method <%@>, which double <%@> does not respond to", selectorString, instance]
                                   userInfo:nil]
             raise];
        }
        return methodSignature;
    }

    void InvocationMatcher::compare_argument_count_to_method_signature(NSMethodSignature * const methodSignature) const {
        size_t actualArgumentCount = [methodSignature numberOfArguments] - OBJC_DEFAULT_ARGUMENT_COUNT;
        size_t expectedArgumentCount = this->arguments().size();

        if (actualArgumentCount != expectedArgumentCount) {
            NSString * selectorString = NSStringFromSelector(this->selector());
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Wrong number of expected parameters for <%@>; expected: %lu, actual: %lu", selectorString, (unsigned long)expectedArgumentCount, (unsigned long)actualArgumentCount]
                                   userInfo:nil]
             raise];
        }
    }

    void InvocationMatcher::compare_argument_types_to_method_signature(NSMethodSignature * const methodSignature) const {
        size_t index = OBJC_DEFAULT_ARGUMENT_COUNT;
        for (arguments_vector_t::const_iterator cit = this->arguments().begin(); cit != this->arguments().end(); ++cit, ++index) {
            const char * actual_argument_encoding = [methodSignature getArgumentTypeAtIndex:index];
            if (!(*cit)->matches_encoding(actual_argument_encoding)) {
                NSString * selectorString = NSStringFromSelector(this->selector());
                NSString *reason = [NSString stringWithFormat:@"Attempt to compare expected argument <%@> with actual argument type %s; argument #%lu for <%@>",
                                    (*cit)->value_string(),
                                    actual_argument_encoding,
                                    (unsigned long)(index - OBJC_DEFAULT_ARGUMENT_COUNT + 1),
                                    selectorString];
                [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
            }
        }
    }


}}
