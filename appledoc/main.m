//
//  main.m
//  appledoc
//
//  Created by Tomaž Kragelj on 3/12/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "DDCliUtil.h"
#import "CommandLineArgumentsParser.h"

int main(int argc, char *argv[]) {
	@autoreleasepool {
		CommandLineArgumentsParser *argumentsParser = [[CommandLineArgumentsParser alloc] init];
		[argumentsParser registerOption:@"verbose" shortcut:'v' requirement:GBCommandLineValueRequired];
		[argumentsParser parseOptionsWithArguments:argv count:argc block:^(NSString *argument, id value, BOOL *stop) {
			if (value == GBCommandLineArgumentResults.unknownArgument) {
				ddprintf(@"unknown %@\n", argument);
				*stop = YES;
			} else if (value == GBCommandLineArgumentResults.missingValue) {
				ddprintf(@"missing %@\n", argument);
				*stop = YES;
			}
		}];
	}
    return 0;
}
