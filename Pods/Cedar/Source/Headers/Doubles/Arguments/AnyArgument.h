#import "Argument.h"

namespace Cedar { namespace Doubles {

    class AnyArgument : public Argument {
    private:
        AnyArgument & operator=(const AnyArgument &);

    public:
        AnyArgument() {};
        virtual ~AnyArgument() {};
        // Allow default copy ctor.

        virtual const char * const value_encoding() const { return ""; };
        virtual void * value_bytes() const { return NULL; };
        virtual NSString * value_string() const { return @"anything"; };

        virtual bool matches_encoding(const char *) const { return true; }
        virtual bool matches_bytes(void *) const { return true; }

    };

    namespace Arguments {
        static const Argument::shared_ptr_t anything = Argument::shared_ptr_t(new Doubles::AnyArgument());
    }

}}
