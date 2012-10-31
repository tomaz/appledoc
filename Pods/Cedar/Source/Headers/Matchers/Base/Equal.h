#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {

    template<typename T>
    class Equal : public Base<> {
    private:
        Equal<T> & operator=(const Equal<T> &);

    public:
        explicit Equal(const T & expectedValue);
        ~Equal();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    Equal<T> equal(const T & expectedValue) {
        return Equal<T>(expectedValue);
    }

    template<typename T>
    Equal<T>::Equal(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    Equal<T>::~Equal() {
    }

    template<typename T>
    /*virtual*/ NSString * Equal<T>::failure_message_end() const {
        NSString * expectedValueString = Stringifiers::string_for(expectedValue_);
        return [NSString stringWithFormat:@"equal <%@>", expectedValueString];
    }

    template<typename T> template<typename U>
    bool Equal<T>::matches(const U & actualValue) const {
        return Comparators::compare_equal(actualValue, expectedValue_);
    }

#pragma mark equality operators
    template<typename T, typename U>
    bool operator==(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to == expectedValue;
    }

    template<typename T, typename U>
    bool operator==(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy(equal(expectedValue));
        return true;
    }

    template<typename T, typename U>
    bool operator!=(const ActualValue<T> & actualValue, const U & expectedValue) {
        return actualValue.to != expectedValue;
    }

    template<typename T, typename U>
    bool operator!=(const ActualValueMatchProxy<T> & actualValueMatchProxy, const U & expectedValue) {
        actualValueMatchProxy.negate()(equal(expectedValue));
        return true;
    }
}}
