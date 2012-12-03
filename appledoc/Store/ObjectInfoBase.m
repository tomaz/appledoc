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
	if (!self.objectRegistrar) {
		LogWarn(@"No registrar is assigned, can't push %@!", object);
		return;
	}
	[self.objectRegistrar pushRegistrationObject:object];
}

- (id)popRegistrationObject {
	if (!self.objectRegistrar) {
		LogWarn(@"No registrar is assigned, can't pop!");
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

#pragma mark - Helper methods

- (NSString *)uniqueObjectID {
	return nil;
}

- (NSString *)objectCrossRefPathTemplate {
	return nil;
}

@end

#pragma mark - 

@implementation ObjectInfoBase (Logging)

- (NSMutableString *)descriptionStringWithComment {
	NSMutableString *result = [NSMutableString string];
	if (self.comment.sourceString.length > 0) {
		[result appendFormat:@"/** %@*/\n", self.comment.sourceString];
	}
	return result;
}

@end