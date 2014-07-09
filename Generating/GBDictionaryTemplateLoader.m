//
//  GBDictionaryTemplateLoader.m
//  appledoc
//
//  Created by Tomaz Kragelj on 19.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "GRMustacheTemplateLoader_protected.h"
#import "GBDictionaryTemplateLoader.h"

@implementation GBDictionaryTemplateLoader

#pragma mark Initialization & disposal

+ (id)loaderWithDictionary:(NSDictionary *)partials {
	return [[self alloc] initWithDictionary:partials];
}

- (id)initWithDictionary:(NSDictionary *)partials {
	if ((self = [self initWithExtension:nil encoding:NSUTF8StringEncoding])) {
		_partials = partials;
	}
	return self;
}

#pragma GRMustacheTemplateLoader subclass implementation

// This method must be implemented by GRMustacheTemplateLoader subclasses.
// Provided with a partial name, returns an object which uniquely identifies a template.
- (id)templateIdForTemplateNamed:(NSString *)name relativeToTemplateId:(id)baseTemplateId {
	return name;
}

// This method must be implemented by GRMustacheTemplateLoader subclasses.
// Returns a template string.
- (NSString *)templateStringForTemplateId:(id)templateId error:(NSError **)outError {
	return [_partials objectForKey:templateId];
}

@end
