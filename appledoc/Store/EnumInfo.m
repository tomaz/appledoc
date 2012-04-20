//
//  EnumInfo.m
//  appledoc
//
//  Created by Tomaž Kragelj on 4/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "EnumItemInfo.h"
#import "EnumInfo.h"

@implementation EnumInfo

@synthesize enumItems = _enumItems;

#pragma mark - Properties

- (NSMutableArray *)enumItems {
	if (_enumItems) return _enumItems;
	LogStoDebug(@"Initializing enumeration items array due to first access...");
	_enumItems = [[NSMutableArray alloc] init];
	return _enumItems;
}

@end

#pragma mark - 

@implementation EnumInfo (Registrations)

- (void)appendEnumerationItem:(NSString *)name {
	LogStoInfo(@"Creating enumeration item %@...", name);
	EnumItemInfo *info = [[EnumItemInfo alloc] init];
	info.itemName = name;
	[self.enumItems addObject:info];
}

- (void)appendEnumerationValue:(NSString *)value {
	LogStoInfo(@"Appending enumeration item value %@...", value);
	if (self.enumItems.count == 0) {
		LogWarn(@"Can't append enumeration value because no item is registered!");
		return;
	}
	EnumItemInfo *info = [self.enumItems lastObject];
	info.itemValue = value;
}

@end
