
#import "XMLReader.h"
//#import <libxml2/libxml/relaxng.h>
#import <libxml/relaxng.h>

@interface NSString (libxml2Support)
+ (id)stringWithXmlChar:(xmlChar *)xc;
- (xmlChar *)xmlChar;
@end

@implementation NSString (libxml2Support)

+ (id)stringWithXmlChar:(xmlChar *)xc {
    if (!xc) {
        return nil;
    }
    return [NSString stringWithUTF8String:(char *)xc];
}


- (xmlChar *)xmlChar {
    return (unsigned char *)[self UTF8String];
}

@end


@interface XMLReader ()
@property (nonatomic, copy) NSString *path;
@end


@implementation XMLReader

// don't know what this handles. can't get it to fire
static void readerErr(XMLReader *self, const char *msg, xmlParserSeverities severity, xmlTextReaderLocatorPtr locator) {
    NSString *str = [NSString stringWithUTF8String:msg];
    int line = xmlTextReaderLocatorLineNumber(locator);
    NSLog(@"some kinda error! %s, severity: %i, line: %i", msg, severity, line);
    
    switch (severity) {
        case XMLReaderSeverityValidityWarning:
            [self.errorHandler validityWarning:str lineNumber:line];
            break;
        case XMLReaderSeverityValidityError:
            [self.errorHandler validityError:str lineNumber:line];
            break;
        case XMLReaderSeverityWarning:
            [self.errorHandler warning:str lineNumber:line];
            break;
        case XMLReaderSeverityError:
            [self.errorHandler error:str lineNumber:line];
            break;
    }
    
}


// handles well-formedness errors in instance document
// and handles validity errors in instance doc
static void structErr(XMLReader *self, xmlErrorPtr error) {    
    const char *msg = error->message;
    int line = error->line;
    int level = error->level;
    
    NSLog(@"Instance doc well-formedness or validity error, level: %i", level);
    NSLog(@"message: = %s", msg);
    NSLog(@"line: = %i", line);
    
    NSString *str = [NSString stringWithUTF8String:msg];
    
    switch (level) {
        case XML_ERR_WARNING:
            [self.errorHandler warning:str lineNumber:line];
            break;
        case XML_ERR_ERROR:
            [self.errorHandler error:str lineNumber:line];
            break;
        case XML_ERR_FATAL:
            [self.errorHandler fatalError:str lineNumber:line];
            break;
    }
}


+ (id)parserWithContentsOfFile:(NSString *)path {
    return [[[XMLReader alloc] initWithContentsOfFile:path] autorelease];
}

/*
+ (id)parserWithXMLString:(NSString *)XMLString {
    return [[[self alloc] initWithXMLString:XMLStirng] autorelease];
}
*/

- (id)initWithContentsOfFile:(NSString *)newPath {
    if (self = [super init]) {
        self.path = newPath;

        _reader = xmlNewTextReaderFilename([path UTF8String]);
        xmlTextReaderSetParserProp(_reader, XML_PARSE_RECOVER, 1);
        xmlTextReaderSetParserProp(_reader, XML_PARSE_XINCLUDE, 1);
        xmlTextReaderSetErrorHandler(_reader, (xmlTextReaderErrorFunc)readerErr, (void *)self);
        xmlTextReaderSetStructuredErrorHandler(_reader, (xmlStructuredErrorFunc)structErr, (void *)self);
    }
    return self;
}


- (void)dealloc {
    self.path = nil;
    self.errorHandler = nil;
    self.relaxNGSchemaPath = nil;
    if (_reader) {
        xmlFreeTextReader(_reader);
    }
    if (_schema) {
        xmlRelaxNGFree(_schema);
    }
    [super dealloc];
}


#pragma mark -
#pragma mark Properties

- (NSInteger)attributeCount {
    return xmlTextReaderAttributeCount(_reader);
}

    
- (NSString *)baseURI {
    return [NSString stringWithXmlChar:xmlTextReaderBaseUri(_reader)];
}

    
//- (BOOL)canResolveEntity {
//    return YES;
//}

    
- (NSInteger)depth {
    return xmlTextReaderDepth(_reader);
}

    
- (BOOL)isEOF {
    return XMLReaderReadStateEOF == [self readState];
}

    
- (BOOL)hasAttributes {
    return xmlTextReaderHasAttributes(_reader);
}

    
- (BOOL)hasValue {
    return xmlTextReaderHasValue(_reader);
}

    
- (BOOL)isDefault {
    return xmlTextReaderIsDefault(_reader);
}

    
- (BOOL)isEmptyElement {
    return xmlTextReaderIsEmptyElement(_reader);
}

    
- (NSString *)localName {
    xmlChar *c = xmlTextReaderLocalName(_reader);
    if (c) {
        return [NSString stringWithXmlChar:c];
    }
    return nil;
}

    
- (NSString *)name {
    xmlChar *c = xmlTextReaderName(_reader);
    if (c) {
        return [NSString stringWithXmlChar:c];
    }
    return nil;
}

    
- (NSString *)namespaceURI {
    xmlChar *c = xmlTextReaderNamespaceUri(_reader);
    if (c) {
        return [NSString stringWithXmlChar:c];
    }
    return nil;
}


#pragma mark -
#pragma mark Methods

- (XMLReaderNodeType)nodeType {
    return xmlTextReaderNodeType(_reader);
}

    
- (NSString *)prefix {
    return [NSString stringWithXmlChar:xmlTextReaderPrefix(_reader)];
}

    
- (char)quoteChar {
    return xmlTextReaderQuoteChar(_reader);
}

    
- (XMLReaderReadState)readState {
    return xmlTextReaderReadState(_reader);
}

    
- (NSString *)value {
    return [NSString stringWithXmlChar:xmlTextReaderValue(_reader)];
}

    
- (NSString *)XMLLang {
    return [NSString stringWithXmlChar:xmlTextReaderXmlLang(_reader)];
}


- (void)close {
    xmlTextReaderClose(_reader);
}

    
- (NSString *)attributeAtIndex:(NSInteger)index {
    return [NSString stringWithXmlChar:xmlTextReaderGetAttributeNo(_reader, index)];
}

    
- (NSString *)attributeWithQName:(NSString *)qName {
    return [NSString stringWithXmlChar:xmlTextReaderGetAttribute(_reader, [qName xmlChar])];
}

    
- (NSString *)attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)nsURI {
    return [NSString stringWithXmlChar:xmlTextReaderGetAttributeNs(_reader, [localName xmlChar], [nsURI xmlChar])];
}

    
+ (BOOL)isName:(NSString *)str {
    return YES;
}

    
+ (BOOL)isNameToken:(NSString *)str {
    return YES;
}

    
- (NSString *)lookupNamespace:(NSString *)prefix {
    return [NSString stringWithXmlChar:xmlTextReaderLookupNamespace(_reader, [prefix xmlChar])];
}

    
- (void)moveToAttributeAtIndex:(NSInteger)index {
    xmlTextReaderMoveToAttributeNo(_reader, index);
}

    
- (BOOL)moveToAttributeWithQName:(NSString *)qName {
    return xmlTextReaderMoveToAttribute(_reader, [qName xmlChar]);
}

    
- (BOOL)moveToAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)nsURI {
    return xmlTextReaderMoveToAttributeNs(_reader, [localName xmlChar], [nsURI xmlChar]);
}

    
- (BOOL)moveToElement {
    return xmlTextReaderMoveToElement(_reader);
}

    
- (BOOL)moveToFirstAttribute {
    return xmlTextReaderMoveToFirstAttribute(_reader);
}

    
- (BOOL)moveToNextAttribute {
    return xmlTextReaderMoveToNextAttribute(_reader);
}

    
- (BOOL)read {
    return xmlTextReaderRead(_reader);
}

    
- (BOOL)readAttributeValue {
    return xmlTextReaderReadAttributeValue(_reader);
}

    
- (NSString *)readElementString {
    return [NSString stringWithXmlChar:xmlTextReaderReadString(_reader)];
}

    
- (NSString *)readInnerXML {
    return [NSString stringWithXmlChar:xmlTextReaderReadInnerXml(_reader)];
}

    
- (NSString *)readOuterXML {
    return [NSString stringWithXmlChar:xmlTextReaderReadOuterXml(_reader)];
}

    
- (NSString *)readString {
    return [NSString stringWithXmlChar:xmlTextReaderReadString(_reader)];
}

    
- (void)skip {
    xmlTextReaderNextSibling(_reader);
}


// handles warnings encountered while parsing RNG schema
static void rngWarn(XMLReader *self, const char *msg, ...) {
    va_list ap;
    va_start(ap, msg);
    
    NSMutableString *str = [NSMutableString stringWithFormat:[NSString stringWithUTF8String:msg], ap];
    NSLog(@"RELAX NG warn: %s", msg);
    va_end(ap);
    
    [str replaceOccurrencesOfString:@"<"
                         withString:@"&lt;"
                            options:0
                              range:NSMakeRange(0, [str length])];
    
    str = [NSString stringWithFormat:@"Warning while parsing RELAX NG schema: %s",msg];
    [self.errorHandler validityWarning:str lineNumber:-1];
}


// handles errors encountered while parsing RNG schema
static void rngErr(XMLReader *self, const char *msg, ...) {
    va_list ap;
    va_start(ap, msg);
    
    NSMutableString *str = [NSMutableString stringWithFormat:[NSString stringWithUTF8String:msg], ap];
    NSLog(@"RELAX NG err %@",str);
    va_end(ap);
    
    [str replaceOccurrencesOfString:@"<"
                         withString:@"&lt;"
                            options:0
                              range:NSMakeRange(0, [str length])];
    
    str = [NSString stringWithFormat:@"Error while parsing RELAX NG schema: <br/><pre>%@</pre>",str];
    [self.errorHandler validityError:str lineNumber:-1];
    
}


- (NSString *)relaxNGSchemaPath {
    return [[relaxNGSchemaPath retain] autorelease];
}


- (void)setRelaxNGSchemaPath:(NSString *)newPath {
    if (relaxNGSchemaPath != newPath) {
        [relaxNGSchemaPath autorelease];
        relaxNGSchemaPath = [newPath retain];

        const char *schemafurl = [relaxNGSchemaPath UTF8String];
        
        // RELAX NG Parser Context
        xmlRelaxNGParserCtxtPtr ctxt = xmlRelaxNGNewParserCtxt(schemafurl);
        xmlRelaxNGSetParserErrors(ctxt,
                                  (xmlRelaxNGValidityErrorFunc)rngErr,
                                  (xmlRelaxNGValidityWarningFunc)rngWarn,
                                  (void *)self);
        //    xmlRelaxNGSetParserStructuredErrors(ctxt, (xmlStructuredErrorFunc)structErr, NULL);
        
        if (_schema) {
            xmlRelaxNGFree(_schema);
            _schema = NULL;
        }
        
        NSLog(@"gonna parse schema");
        _schema = xmlRelaxNGParse(ctxt);
        NSLog(@"did parse schema");
        xmlRelaxNGFreeParserCtxt(ctxt);
        
        if (_reader) {
            xmlFreeTextReader(_reader);
        }
        _reader = xmlNewTextReaderFilename([path UTF8String]);
        xmlTextReaderSetParserProp(_reader, XML_PARSE_RECOVER, 1);
        xmlTextReaderSetParserProp(_reader, XML_PARSE_XINCLUDE, 1);
        
        xmlTextReaderRelaxNGSetSchema(_reader, _schema);
        
        xmlTextReaderSetErrorHandler(_reader, (xmlTextReaderErrorFunc)readerErr, (void *)self);
        
        xmlTextReaderSetStructuredErrorHandler(_reader, (xmlStructuredErrorFunc)structErr, (void *)self);
    }
    
}


- (BOOL)isValid {
    return xmlTextReaderIsValid(_reader);
}

@synthesize path;
@synthesize errorHandler;
@synthesize relaxNGSchemaPath;
@end
