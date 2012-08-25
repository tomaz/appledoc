//
//  ProtocolInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProtocolInfo.h"

@implementation ProtocolInfo
@end

#pragma mark - 

@implementation ProtocolInfo (Logging)

- (NSString *)description {
	if (!self.nameOfProtocol) return @"protocol";
	return [NSString stringWithFormat:@"@protocol %@ w/ %@", self.nameOfProtocol, [super description]];
}

- (NSString *)debugDescription {
	NSMutableString *result = [self descriptionStringWithComment];
	[result appendFormat:@"@protocol %@", self.nameOfProtocol];
	[result appendString:[super debugDescription]];
	return result;
}

@end
