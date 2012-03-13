//
//  Settings.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Settings.h"

@interface Settings ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Settings *parent;
@property (nonatomic, strong) NSMutableDictionary *storage;
@end

#pragma mark -

@implementation Settings

@synthesize name = _name;
@synthesize parent = _parent;
@synthesize storage = _storage;

#pragma mark - Initialization & disposal

+ (id)settingsWithName:(NSString *)name parent:(Settings *)parent {
	return [[self alloc] initWithName:name parent:parent];
}

- (id)initWithName:(NSString *)name parent:(Settings *)parent {
	self = [super init];
	if (self) {
		self.name = name;
		self.parent = parent;
		self.storage = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - Values handling

- (id)objectForKey:(NSString *)key {
	Settings *level = [self settingsForKey:key];
	return [level.storage objectForKey:key];
}
- (void)setObject:(id)value forKey:(NSString *)key {
	return [self.storage setObject:value forKey:key];
}

- (BOOL)boolForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number boolValue];
}
- (void)setBool:(BOOL)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithBool:value];
	[self setObject:number forKey:key];
}

- (NSInteger)integerForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number integerValue];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithInteger:value];
	[self setObject:number forKey:key];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number unsignedIntegerValue];
}
- (void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:value];
	[self setObject:number forKey:key];
}

- (CGFloat)floatForKey:(NSString *)key {
	NSNumber *number = [self objectForKey:key];
	return [number doubleValue];
}
- (void)setFloat:(CGFloat)value forKey:(NSString *)key {
	NSNumber *number = [NSNumber numberWithDouble:value];
	[self setObject:number forKey:key];
}

#pragma mark - Introspection

- (NSString *)nameOfSettingsForKey:(NSString *)key {
	Settings *level = [self settingsForKey:key];
	return level.name;
}

- (Settings *)settingsForKey:(NSString *)key {
	Settings *level = self;
	while (level) {
		if ([level.storage objectForKey:key]) break;
		level = level.parent;
	}
	return level;
}

@end
