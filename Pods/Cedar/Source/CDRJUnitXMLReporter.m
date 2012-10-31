#import "CDRJUnitXMLReporter.h"
#import "CDRExample.h"

@implementation CDRJUnitXMLReporter

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

#pragma mark - Overriden Methods

- (NSString *)failureMessageForExample:(CDRExample *)example {
    return [NSString stringWithFormat:@"%@\n%@\n", example.fullText, example.failure];
}

- (void)reportOnExample:(CDRExample *)example {
    switch (example.state) {
        case CDRExampleStatePassed:
            [successMessages_ addObject:example.fullText];
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
    [super runDidComplete];

    NSMutableString *xml = [NSMutableString string];
    [xml appendString:@"<?xml version=\"1.0\"?>\n"];
    [xml appendString:@"<testsuite>\n"];

    for (NSString *spec in successMessages_) {
        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\" />\n", [self escapeString:spec]];
    }

    for (NSString *spec in failureMessages_) {
        NSArray *parts = [spec componentsSeparatedByString:@"\n"];
        NSString *name = [parts objectAtIndex:0];
        NSString *message = [parts objectAtIndex:1];

        [xml appendFormat:@"\t<testcase classname=\"Cedar\" name=\"%@\">\n", [self escapeString:name]];
        [xml appendFormat:@"\t\t<failure type=\"Failure\">%@</failure>\n", [self escapeString:message]];
        [xml appendString:@"\t</testcase>\n"];
    }
    [xml appendString:@"</testsuite>\n"];

    [self writeXmlToFile:xml];
}

#pragma mark - Private

- (NSString *)escapeString:(NSString *)unescaped {
    NSString *escaped = [unescaped stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    escaped = [escaped stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return [escaped stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
}

- (void)writeXmlToFile:(NSString *)xml {
    char *xmlFile = getenv("CEDAR_JUNIT_XML_FILE");
    if (!xmlFile) xmlFile = "build/TEST-Cedar.xml";

    [xml writeToFile:[NSString stringWithUTF8String:xmlFile]
          atomically:YES
            encoding:NSUTF8StringEncoding
               error:NULL];
}
@end
