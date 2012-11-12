//
//  OCMockito - MKTObjectMock.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTBaseMockObject.h"


/**
    Mock object of a given class.
 */
@interface MKTObjectMock : MKTBaseMockObject

+ (id)mockForClass:(Class)aClass;
- (id)initWithClass:(Class)aClass;

@end
