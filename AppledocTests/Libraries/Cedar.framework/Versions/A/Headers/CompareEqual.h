namespace Cedar { namespace Matchers { namespace Comparators {

#pragma mark Generic
    template<typename T, typename U>
    bool compare_equal(const T & actualValue, const U & expectedValue) {
        if (strcmp(@encode(T), "@") == 0 && strcmp(@encode(U), "@") == 0) {
            NSValue *actualValueId = [NSValue value:&actualValue withObjCType:@encode(id)];
            NSValue *expectedValueId = [NSValue value:&expectedValue withObjCType:@encode(id)];
            return [[actualValueId nonretainedObjectValue] isEqual:[expectedValueId nonretainedObjectValue]];
        } else {
            return actualValue == expectedValue;
        }
    }

#pragma mark NSNumber
    inline bool compare_equal(NSNumber * const actualValue, NSNumber * const expectedValue) {
        return [actualValue isEqualToNumber:expectedValue];
    }

    inline bool compare_equal(NSNumber * const actualValue, const id expectedValue) {
        return [expectedValue isEqual:actualValue];
    }

    inline bool compare_equal(NSNumber * const actualValue, NSObject * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(NSNumber * const actualValue, NSValue * const expectedValue) {
        return compare_equal(actualValue, static_cast<const id>(expectedValue));
    }

    inline bool compare_equal(const id actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

    inline bool compare_equal(NSObject * const actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

    template<typename U>
    bool compare_equal(NSNumber * const actualValue, const U & expectedValue) {
        return [actualValue floatValue] == expectedValue;
    }

    template<typename T>
    bool compare_equal(const T & actualValue, NSNumber * const expectedValue) {
        return compare_equal(expectedValue, actualValue);
    }

}}}
