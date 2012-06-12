#import "Base.h"

namespace Cedar { namespace Matchers {
    template<typename T>
    class <#MatcherClassName#> : public Base<> {
    private:
        <#MatcherClassName#> & operator=(const <#MatcherClassName#> &);

    public:
        explicit <#MatcherClassName#>(const T & expectedValue);
        ~<#MatcherClassName#>();
        // Allow default copy ctor.

        template<typename U>
        bool matches(const U &) const;

        // For pointer-specific matching.
        template<typename U>
        bool matches(U * const &) const;

        // For type-specific matching
        bool matches(const <#SomeType#> &) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const T & expectedValue_;
    };

    template<typename T>
    <#MatcherClassName#><T> <#MatcherName#>(const T & expectedValue) {
        return <#MatcherClassName#><T>(expectedValue);
    }

    template<typename T>
    <#MatcherClassName#><T>::<#MatcherClassName#>(const T & expectedValue)
    : Base<>(), expectedValue_(expectedValue) {
    }

    template<typename T>
    <#MatcherClassName#><T>::~<#MatcherClassName#>() {
    }

    template<typename T>
    /*virtual*/ NSString * <#MatcherClassName#><T>::failure_message_end() const {
        return [NSString stringWithFormat:@"be related in some way to <%@>", this->string_for(expectedValue_)];
    }

#pragma mark Generic
    template<typename T> template<typename U>
    bool <#MatcherClassName#><T>::matches(const U & actualValue) const {
        // return result of appropriate comparison
    }

#pragma mark <#SomeType#>
    template<typename T>
    bool <#MatcherClassName#><T>::matches(const <#SomeType#> & actualValue) const {
        // return result of appropriate comparison with specific type
    }
}}
