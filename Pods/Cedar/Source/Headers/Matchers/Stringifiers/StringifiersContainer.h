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
                
                NSString * string = string_for(*it);
                [result appendString:[NSString stringWithFormat:@"\n    %@", string]];
            }
            return result;
        }
    }

    template<typename T>
    NSString * string_for(const typename std::vector<T> & container) {
        NSString * delimitedList = comma_and_newline_delimited_list(container);
        return [NSString stringWithFormat:@"(%@\n)", delimitedList];
    }

    template<typename T, typename U>
    NSString * string_for(const typename std::map<T, U> & container) {
        NSMutableString *result = [NSMutableString stringWithString:@"{"];

        for (typename std::map<T, U>::const_iterator it = container.begin(); it != container.end(); ++it) {
            NSString * keyString = string_for(it->first);
            NSString * valueString = string_for(it->second);
            [result appendString:[NSString stringWithFormat:@"\n    %@ = %@;", keyString, valueString]];
        }
        [result appendString:@"\n}"];
        return result;
    }

    template<typename T>
    NSString * string_for(const typename std::set<T> & container) {
        NSString * delimitedList = comma_and_newline_delimited_list(container);
        return [NSString stringWithFormat:@"{(%@\n)}", delimitedList];
    }
}}}
