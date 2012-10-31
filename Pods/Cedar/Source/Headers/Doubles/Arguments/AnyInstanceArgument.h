#import "Argument.h"

namespace Cedar { namespace Doubles {

    class AnyInstanceArgument : public Argument {
    private:
        AnyInstanceArgument & operator=(const AnyInstanceArgument &);

    public:
        explicit AnyInstanceArgument(const Class);
        virtual ~AnyInstanceArgument();
        // Allow default copy ctor.

        virtual const char * const value_encoding() const;
        virtual void * value_bytes() const { return NULL; }
        virtual NSString * value_string() const;

        virtual bool matches_encoding(const char *) const;
        virtual bool matches_bytes(void *) const;

    private:
        const Class class_;
    };


    namespace Arguments {
        Argument::shared_ptr_t any(Class);
    }
}}
