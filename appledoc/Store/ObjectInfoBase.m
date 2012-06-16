//
//  ObjectInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "CommentInfo.h"
#import "ObjectInfoBase.h"

@interface ObjectInfoBase ()
@property (nonatomic, strong) PKToken *currentSourceInfo;
@end

#pragma mark - 

@implementation ObjectInfoBase

@synthesize comment = _comment;
@synthesize sourceToken = _sourceToken;
@synthesize currentSourceInfo = _currentSourceInfo;
@synthesize objectRegistrar = _objectRegistrar;

#pragma mark - Initialization & disposal

- (id)initWithRegistrar:(id<StoreRegistrar>)registrar {
	self = [super init];
	if (self) {
		self.objectRegistrar = registrar;
	}
	return self;
}

#pragma mark - StoreRegistrar and related stuff

- (void)pushRegistrationObject:(id)object {
	LogStoDebug(@"Pushing %@ to registration stack...", object);
	if (!self.objectRegistrar) {
		LogStoWarn(@"No registrar is assigned, can't push %@!", object);
		return;
	}
	[self.objectRegistrar pushRegistrationObject:object];
}

- (id)popRegistrationObject {
	LogStoDebug(@"Popping registration stack...");
	if (!self.objectRegistrar) {
		LogStoWarn(@"No registrar is assigned, can't pop!");
		return nil;
	}
	return [self.objectRegistrar popRegistrationObject];
}

- (BOOL)expectCurrentRegistrationObjectRespondTo:(SEL)selector {
	return [self.objectRegistrar expectCurrentRegistrationObjectRespondTo:selector];
}

- (BOOL)doesCurrentRegistrationObjectRespondTo:(SEL)selector {
	return [self.objectRegistrar doesCurrentRegistrationObjectRespondTo:selector];
}

- (id)currentRegistrationObject {
	return self.objectRegistrar.currentRegistrationObject;
}

@end
