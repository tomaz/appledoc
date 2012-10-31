#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {

    template<typename T>
    class BeLTE : public Base<> {
    private:
        BeLTE<T> & operator=(const BeLTE<T> &);

    public:
        explicit BeLTE(const T & expectedValue);
        ~BeLTE();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    BeLTE<T> be_lte(const T & expectedValue) {
        return BeLTE<T>(expectedValue);
    }

    template<typename T>
    BeLTE<T> be_less_than_or_equal_to(const T & expectedValue) {
        return be_lte(expectedValue);
    }

    template<typename T>
    BeLTE<T>::BeLTE(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeLTE<T>::~BeLTE() {
    }

    template<typename T>
    /*virtual*/ NSString * BeLTE<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"be less than or equal to <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool BeLTE<T>::matches(const U & actualValue) const {
        return !Comparators::compare_greater_than(actualValue, expectedValue_);
    }

#pragma mark operators
    template<typename T, typename U>
    bool operator<=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to <= expectedValue;
    }

    template<typename T, typename U>
    bool operator<=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(be_lte(expectedValue));
        return true;
    }
}}
