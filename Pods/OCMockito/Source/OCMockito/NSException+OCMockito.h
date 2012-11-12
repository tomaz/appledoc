//
//  OCMockito - NSException+OCMockito.h
//  Copyright 2012 Jonathan M. Reid. See LICENSE.txt
//

#import <Foundation/Foundation.h>


@interface NSException (OCMockito)

+ (NSException *)mkt_failureInFile:(NSString *)fileName
                            atLine:(int)lineNumber
                            reason:(NSString *)reason;

@end
