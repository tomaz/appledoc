#import <vector>
#import <map>
#import <set>

namespace Cedar { namespace Matchers { namespace Stringifiers {
    namespace {
        template <typename Container>
        NSString * comma_and_newline_delimited_list(const Container & container) {
            NSMutableString *result = [NSMutableString string];
            bool first = true;
            for (typename Container::const_iterator it = container.begin(); it != container.end(); ++it, first = false) {
                if (!first) {
                    [result appendString:@","];
                }
                [result appendString:[NSString stringWithFormat:@"\n    %@", string_for(*it)]];
            }
            return result;
        }
    }

    template<typename T>
    NSString * string_for(const typename std::vector<T> & container) {
        return [NSString stringWithFormat:@"(%@\n)", comma_and_newline_delimited_list(container)];
    }

    template<typename T, typename U>
    NSString * string_for(const typename std::map<T, U> & container) {
        NSMutableString *result = [NSMutableString stringWithString:@"{"];

        for (typename std::map<T, U>::const_iterator it = container.begin(); it != container.end(); ++it) {
            [result appendString:[NSString stringWithFormat:@"\n    %@ = %@;", string_for(it->first), string_for(it->second)]];
        }
        [result appendString:@"\n}"];
        return result;
    }

    template<typename T>
    NSString * string_for(const typename std::set<T> & container) {
        return [NSString stringWithFormat:@"{(%@\n)}", comma_and_newline_delimited_list(container)];
    }
}}}
