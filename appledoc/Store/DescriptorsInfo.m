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

@synthesize descriptorItems = _descriptorItems;

#pragma mark - Properties

- (NSMutableArray *)descriptorItems {
	if (_descriptorItems) return _descriptorItems;
	LogStoDebug(@"Initializing descriptor items array due to first access...");
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
