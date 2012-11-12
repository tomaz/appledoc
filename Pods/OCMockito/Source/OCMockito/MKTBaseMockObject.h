//
//  OCMockito - MKTBaseMockObject.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "MKTPrimitiveArgumentMatching.h"


@interface MKTBaseMockObject : NSProxy <MKTPrimitiveArgumentMatching>

- (id)init;

@end
