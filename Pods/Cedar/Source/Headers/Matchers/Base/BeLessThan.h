#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {

    template<typename T>
    class BeLessThan : public Base<> {
    private:
        BeLessThan<T> & operator=(const BeLessThan<T> &);

    public:
        explicit BeLessThan(const T & expectedValue);
        ~BeLessThan();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    BeLessThan<T> be_less_than(const T & expectedValue) {
        return BeLessThan<T>(expectedValue);
    }

    template<typename T>
    BeLessThan<T>::BeLessThan(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeLessThan<T>::~BeLessThan() {
    }

    template<typename T>
    /*virtual*/ NSString * BeLessThan<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be less than <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeLessThan<T>::matches(const U & actualValue) const {
        return !Comparators::compare_greater_than(actualValue, expectedValue_) && !Comparators::compare_equal(actualValue, expectedValue_);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator<(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to < expectedValue;
    }

    template<typename T, typename U>
    bool operator<(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_less_than(expectedValue));
        return true;
    }
}}
