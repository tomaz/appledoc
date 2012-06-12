#import <Foundation/Foundation.h>
#import "CompareEqual.h"
#import "CedarStringifiers.h"
#import "CedarComparators.h"

namespace Cedar { namespace Doubles {

    class Argument {
    public:
        virtual ~Argument() = 0;

        virtual const char * value_encoding() const = 0;
        virtual NSString * value_string() const = 0;

        virtual bool matches_bytes(void * expectedArgumentBytes) const = 0;
    };

    inline /* virtual */ Argument::~Argument() {}

    template<typename T>
    class TypedArgument : public Argument {
    private:
        TypedArgument<T> & operator=(const TypedArgument<T> &);

    public:
        explicit TypedArgument(const T &);
        virtual ~TypedArgument();
        // Allow default copy ctor.

        virtual const char * value_encoding() const;
        virtual NSString * value_string() const;

        virtual bool matches_bytes(void * expectedArgumentBytes) const;

    private:
        const T & value_;
    };


    template<typename T>
    TypedArgument<T>::TypedArgument(const T & value) : Argument(), value_(value) {}

    template<typename T>
    /* virtual */ TypedArgument<T>::~TypedArgument() {}

    template<typename T>
    /* virtual */ const char * TypedArgument<T>::value_encoding() const {
        return @encode(T);
    }

    template<typename T>
    /* virtual */ NSString * TypedArgument<T>::value_string() const {
        return Matchers::Stringifiers::string_for(value_);
    }

    template<typename T>
    /* virtual */ bool TypedArgument<T>::matches_bytes(void * expectedArgumentBytes) const {
        return Matchers::Comparators::compare_equal(value_, *(static_cast<T *>(expectedArgumentBytes)));
    }
}}
