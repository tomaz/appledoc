//
//  OCMockito - NSException+OCMockito.m
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import "NSException+OCMockito.h"


@implementation NSException (OCMockito)

+ (NSException *)mkt_failureInFile:(NSString *)fileName
                            atLine:(int)lineNumber
                            reason:(NSString *)reason
{
    NSNumber *line = [NSNumber numberWithInt:lineNumber];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              fileName, @"SenTestFilenameKey",
                              line, @"SenTestLineNumberKey",
                              nil];
    return [self exceptionWithName:@"SenTestFailureException" reason:reason userInfo:userInfo];
}

@end
