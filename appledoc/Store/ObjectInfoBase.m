//
//  ObjectInfoBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/11/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectInfoBase.h"

@implementation ObjectInfoBase

@synthesize sourceToken = _sourceToken;
@synthesize registrationStack = _registrationStack;
@synthesize currentRegistrationObject = _currentRegistrationObject;

#pragma mark - Registration helpers

- (void)pushRegistrationObject:(id)object {
	LogStoDebug(@"Pushing %@ to registration stack...", object);
	[self.registrationStack addObject:object];
}

- (id)popRegistrationObject {
	LogStoDebug(@"Popping registration stack...");
	id result = self.currentRegistrationObject;
	[self.registrationStack removeLastObject];
	return result;
}

- (BOOL)expectCurrentRegistrationObjectRespondTo:(SEL)selector {
	if (self.registrationStack.count == 0) {
		LogStoWarn(@"Expecting at least one object responding to %@ on registration stack!", NSStringFromSelector(selector));
		return NO;
	}
	if (![self.currentRegistrationObject respondsToSelector:selector]) {
		LogStoWarn(@"Current object %@ on registration stack doesn't respond to %@!", self.currentRegistrationObject, NSStringFromSelector(selector));
		return NO;
	}
	return YES;
}

#pragma mark - Properties

- (id)currentRegistrationObject {
	return [self.registrationStack lastObject];
}

- (NSMutableArray *)registrationStack {
	if (_registrationStack) return _registrationStack;
	LogStoDebug(@"Initializing registration stack due to first access...");
	_registrationStack = [[NSMutableArray alloc] init];
	return _registrationStack;
}

@end
