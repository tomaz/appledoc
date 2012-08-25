//
//  DescriptorsInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/26/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "StoreRegistrations.h"
#import "DescriptorsInfo.h"

@implementation DescriptorsInfo

#pragma mark - Properties

- (NSMutableArray *)descriptorItems {
	if (_descriptorItems) return _descriptorItems;
	LogIntDebug(@"Initializing descriptor items array due to first access...");
	_descriptorItems = [[NSMutableArray alloc] init];
	return _descriptorItems;
}

@end

#pragma mark - 

@implementation DescriptorsInfo (Registrations)

- (void)appendDescriptor:(NSString *)descriptor {
	LogStoInfo(@"Assigning descriptor %@...", descriptor);
	[self.descriptorItems addObject:descriptor];
}

@end

#pragma mark - 

@implementation DescriptorsInfo (Logging)

- (NSString *)description {
	if (!_descriptorItems) return @"descriptors";
	NSMutableString *result = [NSMutableString string];
	[self.descriptorItems enumerateObjectsUsingBlock:^(NSString *descriptor, NSUInteger idx, BOOL *stop) {
		if (idx > 0) [result appendString:@" "];
		[result appendString:descriptor];
	}];
	return result;
}

- (NSString *)debugDescription {
	if (!_descriptorItems) return @"";
	return [self description];
}

@end
