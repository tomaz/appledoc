#import <Foundation/Foundation.h>
#import "CommandLineParser.h"
#import "DoxygenConverter.h"

int main(int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	@try
	{
		// Parse command line arguments. If command line is not ok, print usage and exit.
		CommandLineParser* commandLineParser = [CommandLineParser sharedInstance];
		[commandLineParser parseCommandLineArguments:argv ofCount:argc];
		
		// Create and run the converter.
		DoxygenConverter* converter = [[DoxygenConverter alloc] init];
		[converter convert];
		[converter release];
		
		// Release the command line parser.
		[commandLineParser release];
	}
	@catch (NSException* e)
	{
		NSLog(@"Exiting due to exception: %@", e);
		[[CommandLineParser sharedInstance] printUsage];
		return 1;
	}
	@finally
	{
		[pool drain];
	}
	
    return 0;
}
