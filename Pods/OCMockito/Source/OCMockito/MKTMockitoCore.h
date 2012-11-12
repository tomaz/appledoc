//
//  OCMockito - MKTMockitoCore.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>

#import "MKTTestLocation.h"

@class MKTObjectMock;
@class MKTOngoingStubbing;
@protocol MKTVerificationMode;


@interface MKTMockitoCore : NSObject

+ (id)sharedCore;

- (MKTOngoingStubbing *)stubAtLocation:(MKTTestLocation)location;

- (id)verifyMock:(MKTObjectMock *)mock
        withMode:(id <MKTVerificationMode>)mode
      atLocation:(MKTTestLocation)location;

@end
