//
//  OCMockito - MKTProtocolMock.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "MKTBaseMockObject.h"


/**
    Mock object implementing a given protocol.
 */
@interface MKTProtocolMock : MKTBaseMockObject

+ (id)mockForProtocol:(Protocol *)aClass;
- (id)initWithProtocol:(Protocol *)aClass;

@end
