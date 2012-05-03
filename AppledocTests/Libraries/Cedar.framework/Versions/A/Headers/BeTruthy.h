#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeTruthy : public Base<> {
    private:
        BeTruthy & operator=(const BeTruthy &);

    public:
        inline BeTruthy() : Base<>() {}
        inline ~BeTruthy() {}
        // Allow default copy ctor.

        inline const BeTruthy & operator()() const { return *this; }

        template<typename U>
        bool matches(const U &) const;

    protected:
        inline /*virtual*/ NSString * failure_message_end() const { return @"evaluate to true"; }
    };

    static const BeTruthy be_truthy = BeTruthy();

#pragma mark Generic
    template<typename U>
    bool BeTruthy::matches(const U & actualValue) const {
        return !!actualValue;
    }

}}
