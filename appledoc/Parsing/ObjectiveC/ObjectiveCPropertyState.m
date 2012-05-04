//
//  ObjectiveCPropertyState.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "ObjectiveCPropertyState.h"

@interface ObjectiveCPropertyState ()
@property (nonatomic, strong) NSArray *propertyAttributeDelimiters;
@end

#pragma mark - 

@implementation ObjectiveCPropertyState

@synthesize propertyAttributeDelimiters = _propertyAttributeDelimiters;

#pragma mark - Parsing

- (NSUInteger)parseWithData:(ObjectiveCParseData *)data {
	// Consume @ and property tokens.
	LogParDebug(@"Matched property definition.");
	[data.store setCurrentSourceInfo:data.stream.current];
	[data.store beginPropertyDefinition];
	[data.stream consume:2];

	// Parse attributes.
	if ([data.stream matches:@"(", nil]) {
		LogParDebug(@"Matching attributes...");
		[data.store beginPropertyAttributes];
		NSArray *delimiters = self.propertyAttributeDelimiters;
		NSUInteger found = [data.stream matchStart:@"(" end:@")" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
			LogParDebug(@"Matched %@.", token);
			if ([token matches:delimiters]) return;
			[data.store appendAttribute:token.stringValue];
		}];
		if (found == NSNotFound) {
			LogParDebug(@"Failed matching attributes, bailing out.");
			[data.store cancelCurrentObject]; // attribute types
			[data.store cancelCurrentObject]; // property definition
			[data.parser popState];
			return GBResultFailedMatch;
		}
		[data.store endCurrentObject];
	}
	
	// Parse types, name and descriptors.
	LogParDebug(@"Matching types and name.");
	[data.store beginPropertyTypes];
	NSUInteger found = [data.stream matchUntil:@";" block:^(PKToken *token, NSUInteger lookahead, BOOL *stop) {
		LogParDebug(@"Matched %@.", token);
		if ([token matches:@";"]) {
			return;
		} else if ([[data.stream la:lookahead+1] matches:@";"]) {
			[data.store endCurrentObject];
			[data.store appendPropertyName:token.stringValue];
			return;
		}
		[data.store appendType:token.stringValue];
	}];
	if (found == NSNotFound) {
		LogParDebug(@"Failed matching type and name, bailing out.");
		[data.store cancelCurrentObject];
		[data.parser popState]; 
		return GBResultFailedMatch;
	}
	[data.store endCurrentObject];

	LogParDebug(@"Ending property.");
	[data.parser popState];
	return GBResultOk;
}

#pragma mark - Properties

- (NSArray *)propertyAttributeDelimiters {
	if (_propertyAttributeDelimiters) return _propertyAttributeDelimiters;
	_propertyAttributeDelimiters = [NSArray arrayWithObjects:@"(", @",", @")", nil];
	return _propertyAttributeDelimiters;
}

@end
