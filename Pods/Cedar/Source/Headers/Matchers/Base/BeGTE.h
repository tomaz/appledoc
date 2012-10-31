#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {

    template<typename T>
    class BeGTE : public Base<> {
    private:
        BeGTE<T> & operator=(const BeGTE<T> &);

    public:
        explicit BeGTE(const T & expectedValue);
        ~BeGTE();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    BeGTE<T> be_gte(const T & expectedValue) {
        return BeGTE<T>(expectedValue);
    }

    template<typename T>
    BeGTE<T> be_greater_than_or_equal_to(const T & expectedValue) {
        return be_gte(expectedValue);
    }

    template<typename T>
    BeGTE<T>::BeGTE(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeGTE<T>::~BeGTE() {
    }

    template<typename T>
    /*virtual*/ NSString * BeGTE<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be greater than or equal to <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeGTE<T>::matches(const U & actualValue) const {
        return Comparators::compare_greater_than(actualValue, expectedValue_) || Comparators::compare_equal(actualValue, expectedValue_);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator>=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to >= expectedValue;
    }

    template<typename T, typename U>
    bool operator>=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_gte(expectedValue));
        return true;
    }
}}
