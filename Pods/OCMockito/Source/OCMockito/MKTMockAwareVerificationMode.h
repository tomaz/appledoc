//
//  OCMockito - MKTMockAwareVerificationMode.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "MKTVerificationMode.h"


@class MKTObjectMock;
@protocol MKVerificationMode;


@interface MKTMockAwareVerificationMode : NSObject <MKTVerificationMode>

+ (id)verificationWithMock:(MKTObjectMock *)aMock mode:(id <MKTVerificationMode>)aMode;
- (id)initWithMock:(MKTObjectMock *)mock mode:(id <MKTVerificationMode>)mode;

@end
