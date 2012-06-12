#import <vector>
#import <map>
#import <set>
#import <algorithm>

// Container
namespace Cedar { namespace Matchers { namespace Comparators {
#pragma mark compare_empty
    template<typename T>
    bool compare_empty(const T & container) {
        return 0 == [container count];
    }

    template<typename T>
    bool compare_empty(const typename std::vector<T> & container) {
        return container.empty();
    }

    template<typename T, typename U>
    bool compare_empty(const typename std::map<T, U> & container) {
        return container.empty();
    }

    template<typename T>
    bool compare_empty(const typename std::set<T> & container) {
        return container.empty();
    }

#pragma mark compare_contains
    template<typename T, typename U>
    bool compare_contains(const T & container, const U & element) {
        return [container containsObject:element];
    }

    template<typename U>
    bool compare_contains(NSString * const container, const U & element) {
        NSRange range = [container rangeOfString:element];
        return container && range.location != NSNotFound;
    }

    template<typename U>
    bool compare_contains(NSMutableString * const container, const U & element) {
        return compare_contains(static_cast<NSString * const>(container), element);
    }

    template<typename U>
    bool compare_contains(NSDictionary * const container, const U & element) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'contain' matcher with dictionary; use contain_key or contain_value" userInfo:nil] raise];
        return false;
    }

    template<typename U>
    bool compare_contains(NSMutableDictionary * const container, const U & element) {
        return compare_contains(static_cast<NSDictionary * const>(container), element);
    }

    namespace {
        template<typename T>
        class CompareEqualTo {
        private:
            CompareEqualTo & operator=(const CompareEqualTo &);

        public:
            explicit CompareEqualTo(const T & rhs): rhs_(rhs) {}
            // Allow default copy ctor.
            ~CompareEqualTo() {}

            template<typename U>
            bool operator()(const U & lhs) const { return compare_equal(lhs, rhs_); }

        private:
            const T & rhs_;
        };
    }

    template<typename U>
    bool compare_contains(const typename std::vector<U> & container, const U & element) {
        return container.end() != std::find_if(container.begin(), container.end(), CompareEqualTo<U>(element));
    }

    template<typename T, typename U, typename V>
    bool compare_contains(const typename std::map<T, U> & container, const V & element) {
        return compare_contains(static_cast<NSDictionary * const>(nil), element);
    }

    template<typename U>
    bool compare_contains(const typename std::set<U> & container, const U & element) {
        return container.end() != std::find_if(container.begin(), container.end(), CompareEqualTo<U>(element));
    }
}}}
