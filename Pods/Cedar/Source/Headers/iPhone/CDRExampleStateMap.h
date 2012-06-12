#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

@interface CDRExampleStateMap : NSObject {
    CFDictionaryRef stateMap_;
}

+ (id)stateMap;

- (NSString *)descriptionForState:(CDRExampleState)state;

@end
