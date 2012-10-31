#import "Base.h"
#import "Argument.h"
#import "InvocationMatcher.h"

namespace Cedar { namespace Doubles {

    class HaveReceived : public Matchers::Base<>, private InvocationMatcher {
    private:
        HaveReceived & operator=(const HaveReceived &);

    public:
        explicit HaveReceived(const SEL);
        ~HaveReceived();
        // Allow default copy ctor.

        template<typename T>
        HaveReceived & with(const T &);
        template<typename T>
        HaveReceived & and_with(const T & argument) { return with(argument); }

        bool matches(id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        void verify_object_is_a_double(id) const;
    };

    HaveReceived have_received(const SEL expectedSelector);
    HaveReceived have_received(const char * expectedMethod);

    template<typename T>
    HaveReceived & HaveReceived::with(const T & value) {
        this->add_argument(value);
        return *this;
    }

}}
