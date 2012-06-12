namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_greater_than(const T & actualValue, const U & expectedValue) {
        return actualValue > expectedValue;
    }

#pragma mark NSNumber
    inline bool compare_greater_than(NSNumber * const actualValue, NSNumber * const expectedValue) {
        return NSOrderedDescending == [actualValue compare:expectedValue];
    }

    template<typename U>
    bool compare_greater_than(NSNumber * const actualValue, const U & expectedValue) {
        return [actualValue floatValue] > expectedValue;
    }

    inline bool compare_greater_than(NSNumber * const actualValue, const id expectedValue) {
        if ([expectedValue respondsToSelector:@selector(floatValue)]) {
            return compare_greater_than(actualValue, [expectedValue floatValue]);
        }
        return false;
    }

    inline bool compare_greater_than(NSNumber * const actualValue, NSObject * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_greater_than(NSNumber * const actualValue, NSValue * const expectedValue) {
        return compare_greater_than(actualValue, static_cast<const id>(expectedValue));
    }

    template<typename T>
    bool compare_greater_than(const T & actualValue, NSNumber * const expectedValue) {
        return actualValue > [expectedValue floatValue];
    }

    inline bool compare_greater_than(const id actualValue, NSNumber * const expectedValue) {
        if ([actualValue respondsToSelector:@selector(floatValue)]) {
            return compare_greater_than([actualValue floatValue], expectedValue);
        }
        return false;
    }

    inline bool compare_greater_than(NSObject * const actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

    inline bool compare_greater_than(NSValue * const actualValue, NSNumber * const expectedValue) {
        return compare_greater_than(static_cast<const id>(actualValue), expectedValue);
    }

}}}
