//
//  GBTypedefBlockArgument.m
//  appledoc
//
//  Created by Teichmann, Bjoern on 23.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

#import "GBTypedefBlockArgument.h"

#import "GBStore.h"
#import "GBApplicationSettingsProvider.h"

@implementation GBTypedefBlockArgument

+ (id)typedefBlockArgumentWithName:(NSString *)name className:(NSString *) className {
    return [[self alloc] initWithName:name className: className];
}

- (id)initWithName:(NSString *)name className:(NSString *) className {
    NSParameterAssert(name != nil);
    self = [super init];
    if (self) {
        _argumentName = name;
        _argumentClass = className;
    }
    return self;
}


- (NSString *)description {
    return self.name;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@: %@", _argumentClass, _argumentName];
}

- (NSString *) href {
    
    NSString *href = nil;
    id referencedObject = nil;
    if (!(referencedObject = [[GBStore sharedStore] classWithName: _argumentClass])) {
        if (!(referencedObject = [[GBStore sharedStore] categoryWithName: _argumentClass])) {
            if (!(referencedObject = [[GBStore sharedStore] protocolWithName: _argumentClass])) {
                if (!(referencedObject = [[GBStore sharedStore] typedefEnumWithName: _argumentClass])) {
                    if (!(referencedObject = [[GBStore sharedStore] typedefBlockWithName: _argumentClass])) {
                        referencedObject = [[GBStore sharedStore] documentWithName: _argumentClass];
                    }
                }
            }
        }
    }
    
    if (referencedObject != nil) {
        NSString *relPath = [[GBApplicationSettingsProvider sharedApplicationSettingsProvider] htmlRelativePathToIndexFromObject: self];
        NSString *linkPath = [[GBApplicationSettingsProvider sharedApplicationSettingsProvider] htmlReferenceForObject:referencedObject fromSource: nil];
        
        href = [relPath stringByAppendingPathComponent: linkPath];
    }

    return href;
}

@synthesize name = _argumentName;
@synthesize className = _argumentClass;


@end
