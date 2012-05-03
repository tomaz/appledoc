#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class BeSameInstanceAs : public Base<> {
    private:
        BeSameInstanceAs & operator=(const BeSameInstanceAs &);

    public:
        explicit BeSameInstanceAs(T * const expectedValue);
        ~BeSameInstanceAs();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        template<typename U>
        bool matches(U * const &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T * expectedValue_;
    };

    template<typename T>
    BeSameInstanceAs<T> be_same_instance_as(T * const expectedValue) {
        return BeSameInstanceAs<T>(expectedValue);
    }

    template<typename T>
    BeSameInstanceAs<T>::BeSameInstanceAs(T * const expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    BeSameInstanceAs<T>::~BeSameInstanceAs() {
    }

    template<typename T>
    /*virtual*/ NSString * BeSameInstanceAs<T>::failure_message_end() const {
        return [NSString stringWithFormat:@"be same instance as <%p>", expectedValue_];
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool BeSameInstanceAs<T>::matches(const U & actualValue) const {
        [[CDRSpecFailure specFailureWithReason:@"Attempt to compare non-pointer type for sameness."] raise];
        return NO;
    }

    template<typename T> template<typename U>
    bool BeSameInstanceAs<T>::matches(U * const & actualValue) const {
        return actualValue == expectedValue_;
    }

}}
