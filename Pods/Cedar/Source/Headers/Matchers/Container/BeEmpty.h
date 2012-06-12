#import "Base.h"

namespace Cedar { namespace Matchers {
    class BeEmpty : public Base<> {
    private:
        BeEmpty & operator=(const BeEmpty &);

    public:
        inline BeEmpty() : Base<>() {}
        inline ~BeEmpty() {}
        // Allow default copy ctor.

        inline const BeEmpty & operator()() const { return *this; }

        template<typename U>
        bool matches(const U &) const;

    protected:
        inline /*virtual*/ NSString * failure_message_end() const { return @"be empty"; }
    };

    static const BeEmpty be_empty = BeEmpty();

#pragma mark Generic
    template<typename U>
    bool BeEmpty::matches(const U & actualValue) const {
        return Comparators::compare_empty(actualValue);
    }
}}
