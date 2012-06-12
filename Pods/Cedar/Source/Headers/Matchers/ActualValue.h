#import <Foundation/Foundation.h>
#import <iostream>

#import "StringifiersBase.h"
#import "CDRSpecFailure.h"

namespace Cedar { namespace Matchers {

    void CDR_fail(const char *fileName, int lineNumber, NSString * reason);

    template<typename T> class ActualValue;

#pragma mark class ActualValueMatchProxy
    template<typename T>
    class ActualValueMatchProxy {
    private:
        template<typename U>
        ActualValueMatchProxy(const ActualValueMatchProxy<U> &);
        template<typename U>
        ActualValueMatchProxy & operator=(const ActualValueMatchProxy<U> &);

    public:
        explicit ActualValueMatchProxy(const ActualValue<T> &, bool negate = false);
        ActualValueMatchProxy();

        template<typename MatcherType> void operator()(const MatcherType &) const;
        ActualValueMatchProxy<T> negate() const;

    private:
        const ActualValue<T> & actualValue_;
        bool negate_;
    };

    template<typename T>
    ActualValueMatchProxy<T>::ActualValueMatchProxy(const ActualValue<T> & actualValue, bool negate /*= false */)
    : actualValue_(actualValue), negate_(negate) {}

    template<typename T> template<typename MatcherType>
    void ActualValueMatchProxy<T>::operator()(const MatcherType & matcher) const {
        if (negate_) {
            actualValue_.execute_negative_match(matcher);
        } else {
            actualValue_.execute_positive_match(matcher);
        }
    }

    template<typename T>
    ActualValueMatchProxy<T> ActualValueMatchProxy<T>::negate() const {
        return ActualValueMatchProxy<T>(actualValue_, !negate_);
    }

#pragma mark class ActualValue
    template<typename T>
    class ActualValue {
    private:
        template<typename U>
        ActualValue(const ActualValue<U> &);
        template<typename U>
        ActualValue & operator=(const ActualValue<U> &);

    public:
        explicit ActualValue(const char *, int, const T &);
        ~ActualValue();

        ActualValueMatchProxy<T> to;
        ActualValueMatchProxy<T> to_not;

    private:
        template<typename MatcherType> void execute_positive_match(const MatcherType &) const;
        template<typename MatcherType> void execute_negative_match(const MatcherType &) const;
        friend class ActualValueMatchProxy<T>;

    private:
        const T & value_;
        std::string fileName_;
        int lineNumber_;
    };

    template<typename T>
    ActualValue<T>::ActualValue(const char *fileName, int lineNumber, const T & value) : fileName_(fileName), lineNumber_(lineNumber), value_(value), to(*this), to_not(*this, true) {
    }

    template<typename T>
    ActualValue<T>::~ActualValue() {
    }

    template<typename T> template<typename MatcherType>
    void ActualValue<T>::execute_positive_match(const MatcherType & matcher) const {
        if (!matcher.matches(value_)) {
            CDR_fail(fileName_.c_str(), lineNumber_, matcher.failure_message_for(value_));
        }
    }

    template<typename T> template<typename MatcherType>
    void ActualValue<T>::execute_negative_match(const MatcherType & matcher) const {
        if (matcher.matches(value_)) {
            CDR_fail(fileName_.c_str(), lineNumber_, matcher.negative_failure_message_for(value_));
        }
    }

    template<typename T>
    const ActualValue<T> CDR_expect(const char *fileName, int lineNumber, const T & actualValue) {
        return ActualValue<T>(fileName, lineNumber, actualValue);
    }

    inline void CDR_fail(const char *fileName, int lineNumber, NSString * reason) {
        [[CDRSpecFailure specFailureWithReason:reason
                                      fileName:[NSString stringWithUTF8String:fileName]
                                    lineNumber:lineNumber] raise];
    }

}}

#ifndef CEDAR_MATCHERS_COMPATIBILITY_MODE
    #define expect(x) CDR_expect(__FILE__, __LINE__, (x))
    #define fail(x) CDR_fail(__FILE__, __LINE__, (x))
#endif
