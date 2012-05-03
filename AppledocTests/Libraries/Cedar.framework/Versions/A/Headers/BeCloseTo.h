#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class BeCloseTo : public Base<> {
    private:
        BeCloseTo<T> & operator=(const BeCloseTo<T> &);

    public:
        explicit BeCloseTo(const T & expectedValue);
        ~BeCloseTo();
        // Allow default copy ctor.

        BeCloseTo<T> & within(float threshold);

        template<typename U>
        bool matches(const U &) const;
        bool matches(NSNumber * const &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        template<typename U, typename V>
        bool subtractable_types_match(const U &, const V &) const;

    private:
        const T & expectedValue_;
        float threshold_;
    };

    template<typename T>
    BeCloseTo<T> be_close_to(const T & expectedValue) {
        return BeCloseTo<T>(expectedValue);
    }

    template<typename T>
    BeCloseTo<T>::BeCloseTo(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue), threshold_(0.01) {
    }

    template<typename T>
    BeCloseTo<T>::~BeCloseTo() {
    }

    template<typename T>
    BeCloseTo<T> & BeCloseTo<T>::within(float threshold) {
        threshold_ = threshold;
        return *this;
    }

    template<typename T>
    /*virtual*/ NSString * BeCloseTo<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"be close to <%@> (within %@)", Stringifiers::string_for(expectedValue_), Stringifiers::string_for(threshold_)];
    }

    template<typename T> template<typename U, typename V>
    bool BeCloseTo<T>::subtractable_types_match(const U & actualValue, const V & expectedValue) const {
        return actualValue > expectedValue - threshold_ && actualValue < expectedValue + threshold_;
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool BeCloseTo<T>::matches(const U & actualValue) const {
        return this->subtractable_types_match(actualValue, expectedValue_);
    }

#pragma mark NSNumber
    template<typename T>
    bool BeCloseTo<T>::matches(NSNumber * const & actualValue) const {
        return this->matches([actualValue floatValue]);
    }

    template<> template<typename U>
    bool BeCloseTo<NSNumber *>::matches(const U & actualValue) const {
        return this->subtractable_types_match(actualValue, [expectedValue_ floatValue]);
    }
}}
