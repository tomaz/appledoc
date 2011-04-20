//
//  XMLReader.h
//  XMLReader
//
//  Created by Todd Ditchendorf on 6/5/06.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <libxml2/libxml/xmlreader.h>
#import <libxml/xmlreader.h>

/**
 * XMLReaderMode:
 *
 * Internal state values for the reader.
 */    
typedef enum {
    XMLReaderReadStateInitial = 0,
    XMLReaderReadStateInteractive = 1,
    XMLReaderReadStateError = 2,
    XMLReaderReadStateEOF = 3,
    XMLReaderReadStateClosed = 4,
    XMLReaderReadStateReading = 5
} XMLReaderReadState;

/**
 * xmlParserProperties:
 *
 * Some common options to use with xmlTextReaderSetParserProp, but it
 * is better to use xmlParserOption and the xmlReaderNewxxx and 
 * xmlReaderForxxx APIs now.
 *
typedef enum {
    XML_PARSER_LOADDTD = 1,
    XML_PARSER_DEFAULTATTRS = 2,
    XML_PARSER_VALIDATE = 3,
    XML_PARSER_SUBST_ENTITIES = 4
} xmlParserProperties;
*/

/**
 * xmlParserSeverities:
 *
 * How severe an error callback is when the per-reader error callback API
 * is used.
 */
typedef enum {
    XMLReaderSeverityValidityWarning = 1,
    XMLReaderSeverityValidityError = 2,
    XMLReaderSeverityWarning = 3,
    XMLReaderSeverityError = 4
} XMLReaderSeverity;

/**
 * XMLReaderNodeType:
 *
 * Predefined constants for the different types of nodes.
 */
typedef enum {
    XMLReaderNodeTypeNone = 0,
    XMLReaderNodeTypeElement = 1,
    XMLReaderNodeTypeAttribute = 2,
    XMLReaderNodeTypeText = 3,
    XMLReaderNodeTypeCDATA = 4,
    XMLReaderNodeTypeEntityReference = 5,
    XMLReaderNodeTypeEntity = 6,
    XMLReaderNodeTypeProcessingInstruction = 7,
    XMLReaderNodeTypeComment = 8,
    XMLReaderNodeTypeDocument = 9,
    XMLReaderNodeTypeDocumentType = 10,
    XMLReaderNodeTypeDocumentFragment = 11,
    XMLReaderNodeTypeNotation = 12,
    XMLReaderNodeTypeWhitespace = 13,
    XMLReaderNodeTypeSignificantWhitespace = 14,
    XMLReaderNodeTypeEndElement = 15,
    XMLReaderNodeTypeEndEntity = 16,
    XMLReaderNodeTypeXmlDeclaration = 17
} XMLReaderNodeType;


@interface NSObject (XMLReaderErrorHandler)
- (void)validityWarning:(NSString *)msg lineNumber:(NSInteger)n;
- (void)validityError:(NSString *)msg lineNumber:(NSInteger)n;
- (void)warning:(NSString *)msg lineNumber:(NSInteger)n;
- (void)error:(NSString *)msg lineNumber:(NSInteger)n;
- (void)fatalError:(NSString *)msg lineNumber:(NSInteger)n;
@end

@interface XMLReader : NSObject {
    xmlTextReaderPtr _reader;
    xmlRelaxNGPtr _schema;
    NSString *path;
    id errorHandler;
    NSString *relaxNGSchemaPath;
}

+ (id)parserWithContentsOfFile:(NSString *)newPath;
//+ (id)parserWithXMLString:(NSString *)XMLString;

- (id)initWithContentsOfFile:(NSString *)path;
//- (id)initWithXMLString:(NSString *)XMLString;

// Gets the number of attributes on the current node.
@property (nonatomic, readonly) NSInteger attributeCount;
//- (NSInteger)attributeCount;

// Gets the base Uniform Resource Identifier (URI) of the current node.
@property (nonatomic, readonly, copy) NSString *baseURI;
//- (NSString *)baseURI;

// Gets a value indicating whether this reader can parse and resolve entities.
//@property (nonatomic, readonly) BOOL canResolveEntity;
//- (BOOL)canResolveEntity;

// Gets the depth of the current node in the XML document.
@property (nonatomic, readonly) NSInteger depth;
//- (NSInteger)depth;

// Gets a value indicating whether the XMLReader.ReadState is ReadState.EndOfFile, signifying the reader is positioned at the end of the stream.
@property (nonatomic, readonly) BOOL isEOF;
//- (BOOL)isEOF;

// Gets a value indicating whether the current node has any attributes.
@property (nonatomic, readonly) BOOL hasAttributes;
//- (BOOL)hasAttributes;

// Gets a value indicating whether the current node can have an associated text value.
@property (nonatomic, readonly) BOOL hasValue;
//- (BOOL)hasValue;

// Gets a value indicating whether the current node is an attribute that was generated from the default value defined in the DTD or schema.
@property (nonatomic, readonly) BOOL isDefault;
//- (BOOL)isDefault;

// Gets a value indicating whether the current node is an empty element (for example, <MyElement />).
@property (nonatomic, readonly) BOOL isEmptyElement;
//- (BOOL)isEmptyElement;

// Gets the local name of the current node.
@property (nonatomic, readonly, copy) NSString *localName;
//- (NSString *)localName;

// Gets the qualified name of the current node.
@property (nonatomic, readonly, copy) NSString *name;
//- (NSString *)name;

// Gets the namespace URI associated with the node on which the reader is positioned.
@property (nonatomic, readonly, copy) NSString *namespaceURI;
//- (NSString *)namespaceURI;

// Gets the name table used by the current instance to store and look up element and attribute names, prefixes, and namespaces.
//- (XmlNameTable)NameTable;

// Gets the type of the current node.
@property (nonatomic, readonly) XMLReaderNodeType nodeType;
//- (XMLReaderNodeType)nodeType;

// Gets the namespace prefix associated with the current node.
@property (nonatomic, readonly, copy) NSString *prefix;
//- (NSString *)prefix;

// Gets the quotation mark character used to enclose the value of an attribute.
@property (nonatomic, readonly) char quoteChar;
//- (char)quoteChar;

// Gets the read state of the reader.
@property (nonatomic, readonly) XMLReaderReadState readState;
//- (XMLReaderReadState)readState;

// Gets the text value of the current node.
@property (nonatomic, readonly, copy) NSString *value;
//- (NSString *)value;

// Gets the current xml:lang scope.
@property (nonatomic, readonly, copy) NSString *XMLLang;
//- (NSString *)XMLLang;

// Gets the current xml:space scope.
//- (XMLSpace)XMLSpace;

// Changes the XMLReader.ReadState to XMLReaderReadState.Closed.
- (void)close;

// Returns the value of the attribute with the specified index relative to the containing element.
- (NSString *)attributeAtIndex:(NSInteger)index;
    
// Returns the value of the attribute with the specified qualified name.
- (NSString *)attributeWithQName:(NSString *)qName;

// Returns the value of the attribute with the specified local name and namespace URI.
- (NSString *)attributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)nsURI;

// Determines whether the specified string is a valid XML name.
+ (BOOL)isName:(NSString *)str;
    
// Determines whether the specified string is a valid XML name token (Nmtoken).
+ (BOOL)isNameToken:(NSString *)str;

// Resolves a namespace prefix in the scope of the current element.
- (NSString *)lookupNamespace:(NSString *)prefix;

// Moves the position of the current instance to the attribute with the specified index relative to the containing element.
- (void)moveToAttributeAtIndex:(NSInteger)index;

// Moves the position of the current instance to the attribute with the specified qualified name.
- (BOOL)moveToAttributeWithQName:(NSString *)qName;

// Moves the position of the current instance to the attribute with the specified local name and namespace URI.
- (BOOL)moveToAttributeWithLocalName:(NSString *)localName namespaceURI:(NSString *)nsURI;
    
// Moves the position of the current instance to the node that contains the current Attribute node.
- (BOOL)moveToElement;

// Moves the position of the current instance to the first attribute associated with the current node.    
- (BOOL)moveToFirstAttribute;

// Moves the position of the current instance to the next attribute associated with the current node.
- (BOOL)moveToNextAttribute;

// Moves the position of the current instance to the next node in the stream, exposing its properties.    
- (BOOL)read;
    
// Parses an attribute value into one or more Text, EntityReference, and EndEntity nodes.
- (BOOL)readAttributeValue;

// Reads the contents of a text-only element.
- (NSString *)readElementString;

// Reads the contents of the current node, including child nodes and markup.
- (NSString *)readInnerXML;

// Reads the current node and its contents, including child nodes and markup.
- (NSString *)readOuterXML;

// Reads the contents of an element or text node as a string.
- (NSString *)readString;

// Skips over the current element and moves the position of the current instance to the next node in the stream.
- (void)skip;

@property (nonatomic, copy) NSString *relaxNGSchemaPath;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, retain) id errorHandler;
@end
