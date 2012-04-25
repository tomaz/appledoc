//
//  ProtocolInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ProtocolInfo.h"

@implementation ProtocolInfo

@synthesize nameOfProtocol;

@end

#pragma mark - 

@implementation ProtocolInfo (Logging)

- (NSString *)description {
	NSMutableString *result = [NSMutableString string];
	[result appendFormat:@"@protocol %@", self.nameOfProtocol];
	[result appendString:[super description]];
	return result;
}

@end
