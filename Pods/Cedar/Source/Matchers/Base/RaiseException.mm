#import "RaiseException.h"

namespace Cedar { namespace Matchers {

#pragma mark - RaiseException
    RaiseException::RaiseException(NSObject *expectedExceptionInstance /*= nil*/,
                                          Class expectedExceptionClass /*= nil*/,
                                          bool allowSubclasses /*= false */,
                                          NSString *reason /*= nil*/) :
    Base<RaiseExceptionMessageBuilder>(),
    expectedExceptionInstance_([expectedExceptionInstance retain]),
    expectedExceptionClass_(expectedExceptionClass),
    allowSubclasses_(allowSubclasses),
    expectedReason_([reason retain]) {
    }

    RaiseException::~RaiseException() {
        [expectedExceptionInstance_ release];
        [expectedReason_ release];
    }

    RaiseException RaiseException::operator()() const {
        return RaiseException();
    }

    RaiseException RaiseException::operator()(Class expectedExceptionClass) const {
        return RaiseException(nil, expectedExceptionClass);
    }

    RaiseException RaiseException::operator()(NSObject *expectedExceptionInstance) const {
        return RaiseException(expectedExceptionInstance);
    }


    RaiseException & RaiseException::or_subclass() {
        allowSubclasses_ = true;
        return *this;
    }

    RaiseException & RaiseException::with_reason(NSString * const reason) {
        expectedReason_ = reason;
        return *this;
    }

    RaiseException RaiseException::with_reason(NSString * const reason) const {
        return RaiseException(nil, nil, false, reason);
    }

#pragma mark - Exception matcher
    bool RaiseException::matches(empty_block_t block) const {
        @try {
            block();
        }
        @catch (NSObject *exception) {
            return this->exception_matches_expected_class(exception) &&
            this->exception_matches_expected_instance(exception) &&
            this->exception_matches_expected_reason(exception);
        }
        return false;
    }

    /*virtual*/ NSString * RaiseException::failure_message_end() const {
        NSMutableString *message = [NSMutableString stringWithFormat:@"raise an exception"];
        if (expectedExceptionClass_) {
            [message appendString:@" of class"];
            if (allowSubclasses_) {
                [message appendString:@", or subclass of class,"];
            }
            [message appendFormat:@" <%@>", NSStringFromClass(expectedExceptionClass_)];
        }
        if (expectedReason_) {
            [message appendFormat:@" with reason <%@>", expectedReason_];
        }

        return message;
    }

#pragma mark - Private interface
    bool RaiseException::exception_matches_expected_class(NSObject * const exception) const {
        return !expectedExceptionClass_ || (allowSubclasses_ ? [exception isKindOfClass:expectedExceptionClass_] : [exception isMemberOfClass:expectedExceptionClass_]);
    }

    bool RaiseException::exception_matches_expected_instance(NSObject * const exception) const {
        return !expectedExceptionInstance_ || [expectedExceptionInstance_ isEqual:exception];
    }

    bool RaiseException::exception_matches_expected_reason(NSObject * const exception) const {
        return !expectedReason_ || ([exception isKindOfClass:[NSException class]] && [expectedReason_ isEqualToString:[id(exception) reason]]);
    }

    // Deprecated
    RaiseException raise() {
        return RaiseException();
    }

}}
