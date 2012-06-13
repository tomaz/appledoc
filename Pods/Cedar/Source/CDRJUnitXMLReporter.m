#import "CDRJUnitXMLReporter.h"
#import "CDRExample.h"

@implementation CDRJUnitXMLReporter

#pragma mark - Memory
- (id)init {
    if (self = [super init]) {
        successMessages_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [successMessages_ release];
    [super dealloc];
}

#pragma mark - Private

- (NSString *)escapeAttribute:(NSString *)s {
    NSMutableString *escaped = [NSMutableString stringWithString:s];

    [escaped setString:[escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"]];
    [escaped setString:[escaped stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"]];

    return escaped;
}

- (NSString *)escape:(NSString *)s {
    NSMutableString *escaped = [NSMutableString stringWithString:s];

    [escaped setString:[escaped stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]];
    [escaped setString:[escaped stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]];
    [escaped setString:[escaped stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]];

    return escaped;
}

- (void)writeXmlToFile:(NSString *)xml {
    char *xmlFile = getenv("CEDAR_JUNIT_XML_FILE");
    if (!xmlFile) {
        xmlFile = "build/TEST-Cedar.xml";
    }

    NSError *error;
    [xml writeToFile:[NSString stringWithUTF8String:xmlFile] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

#pragma mark - Overriden Methods

- (NSString *)failureMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%@\n%@\n",[example fullText], example.failure];
}

- (void)reportOnExample:(CDRExample *)example {
    NSMutableArray *messages = nil;
    switch (example.state) {
        case CDRExampleStatePassed:
            [successMessages_ addObject:[example fullText]];
            break;
        case CDRExampleStateFailed:
        case CDRExampleStateError:
            [failureMessages_ addObject:[self failureMessageForExample:example]];
            break;
        default:
            break;
    }
}

- (void)runDidComplete {
    NSMutableString *xml = [NSMutableString string];
    [xml appendString:@"<?xml version=\"1.0\"?>\n"];
    [xml appendString:@"<testsuite>\n"];

    for (NSString *spec in successMessages_) {
        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\" />\n", [self escapeAttribute:spec]];
    }

    for (NSString *spec in failureMessages_) {
        NSArray *parts = [spec componentsSeparatedByString:@"\n"];
        NSString *name = [parts objectAtIndex:0];
        NSString *message = [parts objectAtIndex:1];

        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\">\n", [self escapeAttribute:name]];
        [xml appendFormat:@"\t\t<failure type=\"Failure\">%@</failure>\n", [self escape:message]];
        [xml appendString:@"\t</testcase>\n"];
    }

    [xml appendString:@"</testsuite>\n"];

    [self writeXmlToFile:xml];
}

@end
