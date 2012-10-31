#import "ValueArgument.h"

namespace Cedar { namespace Doubles {

    template<typename T>
    class ReturnValue : public ValueArgument<T> {
    private:
        ReturnValue & operator=(const ReturnValue &);

    public:
        explicit ReturnValue(const T &);
        virtual ~ReturnValue();

        virtual bool matches_encoding(const char *) const;
    };

    template<typename T>
    ReturnValue<T>::ReturnValue(const T & value) : ValueArgument<T>(value) {}

    template<typename T>
    /* virtual */ ReturnValue<T>::~ReturnValue() {}

    template<typename T>
    /* virtual */ bool ReturnValue<T>::matches_encoding(const char * actual_argument_encoding) const {
        return 0 == strcmp(@encode(T), actual_argument_encoding);
    }

}}
