//
//  GBTypedefBlockData.m
//  appledoc
//
//  Created by Teichmann, Bjoern on 23.06.14.
//  Copyright (c) 2014 Gentle Bytes. All rights reserved.
//

#import "GBTypedefBlockData.h"
#import "GBTypedefBlockArgument.h"

@implementation GBTypedefBlockData

+(id)typedefBlockWithName:(NSString *)name returnType: (NSString *) returnType parameters:(NSArray *)parameters
{
    return [[self alloc] initWithName:name returnType: (NSString *) returnType parameters: parameters];
}

-(id)initWithName:(NSString *)name returnType: (NSString *) returnType parameters: (NSArray *) parameters
{
    self = [super init];
    if(self)
    {
        _blockName = [name copy];
        _parameters = parameters;
        _returnType = returnType;
    }
    return self;
}

- (NSString *)description {
    return self.nameOfBlock;
}

- (BOOL)isTopLevelObject {
    return self.parentObject == nil;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"block %@%@\n%@", _returnType, _blockName, _parameters.debugDescription];
}

- (NSString *) htmlParameterList {
    __block NSString *output = @"";
    for (GBTypedefBlockArgument *param in self.parameters) {
        NSString *formattedClassName = param.className;
        if ([param.href length] > 0) {
            formattedClassName = [NSString stringWithFormat: @"<a href=\"%@\">%@</a>", param.href, formattedClassName];
        }
        output = [output stringByAppendingFormat: @"%@%@ %@", ([output length] > 0 ? @", " : @""), formattedClassName, param.name];
    }
    return output;
}

@synthesize nameOfBlock = _blockName;
@synthesize parameters = _parameters;
@synthesize returnType = _returnType;

@end