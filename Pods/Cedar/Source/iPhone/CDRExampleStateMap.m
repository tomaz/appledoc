#import "CDRExampleStateMap.h"

static CDRExampleStateMap *sharedInstance__;

const CDRExampleState exampleStateKeys[] = {
    CDRExampleStateIncomplete,
    CDRExampleStatePassed,
    CDRExampleStatePending,
    CDRExampleStateSkipped,
    CDRExampleStateFailed,
    CDRExampleStateError
};
const NSString *exampleStateDescriptions[] = {@"RUNNING", @"PASSED", @"PENDING", @"SKIPPED", @"FAILED", @"ERROR"};

@implementation CDRExampleStateMap

+ (id)stateMap {
    if (!sharedInstance__){
        sharedInstance__ = [[CDRExampleStateMap alloc] init];
    }
    return sharedInstance__;
}

- (id)init {
    if (self = [super init]) {
        const size_t keyCount = sizeof(exampleStateKeys)/sizeof(exampleStateKeys[0]);
        const size_t valueCount = sizeof(exampleStateDescriptions)/sizeof(exampleStateDescriptions[0]);
        assert(keyCount == valueCount);
        stateMap_ = CFDictionaryCreate(kCFAllocatorDefault, (const void **)exampleStateKeys, (const void **)exampleStateDescriptions, keyCount, NULL, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (NSString *)descriptionForState:(CDRExampleState)state {
    return (NSString *)CFDictionaryGetValue (stateMap_, (const void **)state);
}


@end
