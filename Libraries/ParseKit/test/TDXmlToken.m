//
//  PKXmlToken.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlToken.h"

@interface TDXmlTokenEOF : TDXmlToken {}
@end

@implementation TDXmlTokenEOF
- (NSString *)description {
    return [NSString stringWithFormat:@"<TDXmlTokenEOF %p>", self];
}
@end

@interface TDXmlToken ()
@property (nonatomic, readwrite, getter=isNone) BOOL none;
@property (nonatomic, readwrite, getter=isStartTag) BOOL startTag;
@property (nonatomic, readwrite, getter=isAttribute) BOOL attribute;
@property (nonatomic, readwrite, getter=isText) BOOL text;
@property (nonatomic, readwrite, getter=isCdata) BOOL cdata;
@property (nonatomic, readwrite, getter=isEntityRef) BOOL entityRef;
@property (nonatomic, readwrite, getter=isEntity) BOOL entity;
@property (nonatomic, readwrite, getter=isProcessingInstruction) BOOL processingInstruction;
@property (nonatomic, readwrite, getter=isComment) BOOL comment;
@property (nonatomic, readwrite, getter=isDocument) BOOL document;
@property (nonatomic, readwrite, getter=isDoctype) BOOL doctype;
@property (nonatomic, readwrite, getter=isFragment) BOOL fragment;
@property (nonatomic, readwrite, getter=isNotation) BOOL notation;
@property (nonatomic, readwrite, getter=isWhitespace) BOOL whitespace;
@property (nonatomic, readwrite, getter=isSignificantWhitespace) BOOL significantWhitespace;
@property (nonatomic, readwrite, getter=isEndTag) BOOL endTag;
@property (nonatomic, readwrite, getter=isEndEntity) BOOL endEntity;
@property (nonatomic, readwrite, getter=isXmlDecl) BOOL xmlDecl;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) TDXmlTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;
@end

@implementation TDXmlToken

+ (TDXmlToken *)EOFToken {
    static TDXmlToken *EOFToken = nil;
    @synchronized (self) {
        if (!EOFToken) {
            EOFToken = [[TDXmlTokenEOF alloc] initWithTokenType:TDTT_XML_EOF stringValue:nil];
        }
    }
    return EOFToken;
}


+ (id)tokenWithTokenType:(TDXmlTokenType)t stringValue:(NSString *)s {
    return [[[self alloc] initWithTokenType:t stringValue:s] autorelease];
}


#pragma mark -

// designated initializer
- (id)initWithTokenType:(TDXmlTokenType)t stringValue:(NSString *)s {
    if (self = [super init]) {
        self.tokenType = t;
        self.stringValue = s;
        
        self.none = (TDTT_XML_NONE == t);
        self.startTag = (TDTT_XML_START_TAG == t);
        self.attribute = (TDTT_XML_ATTRIBUTE == t);
        self.text = (TDTT_XML_TEXT == t);
        self.cdata = (TDTT_XML_CDATA == t);
        self.entityRef = (TDTT_XML_ENTITY_REF == t);
        self.entity = (TDTT_XML_ENTITY == t);
        self.processingInstruction = (TDTT_XML_PROCESSING_INSTRUCTION == t);
        self.comment = (TDTT_XML_COMMENT == t);
        self.document = (TDTT_XML_DOCUMENT == t);
        self.doctype = (TDTT_XML_DOCTYPE == t);
        self.fragment = (TDTT_XML_FRAGMENT == t);
        self.notation = (TDTT_XML_NOTATION == t);
        self.whitespace = (TDTT_XML_WHITESPACE == t);
        self.significantWhitespace = (TDTT_XML_SIGNIFICANT_WHITESPACE == t);
        self.endTag = (TDTT_XML_END_TAG == t);
        self.endEntity = (TDTT_XML_END_ENTITY == t);
        self.xmlDecl = (TDTT_XML_XML_DECL == t);
        
        self.value = stringValue;
    }
    return self;
}


- (void)dealloc {
    self.stringValue = nil;
    self.value = nil;
    [super dealloc];
}


- (NSUInteger)hash {
    return [stringValue hash];
}


- (BOOL)isEqual:(id)rhv {
    if (![rhv isMemberOfClass:[TDXmlToken class]]) {
        return NO;
    }
    
    TDXmlToken *that = (TDXmlToken *)rhv;
    if (tokenType != that.tokenType) {
        return NO;
    }
    
    return [stringValue isEqualToString:that.stringValue];
}


- (BOOL)isEqualIgnoringCase:(id)rhv {
    if (![rhv isMemberOfClass:[TDXmlToken class]]) {
        return NO;
    }
    
    TDXmlToken *that = (TDXmlToken *)rhv;
    if (tokenType != that.tokenType) {
        return NO;
    }
    
    return [stringValue.lowercaseString isEqualToString:that.stringValue.lowercaseString];
}


- (NSString *)debugDescription {
    NSString *typeString = nil;
    if (self.isNone) {
        typeString = @"None";
    } else if (self.isStartTag) {
        typeString = @"Start Tag";
    } else if (self.isAttribute) {
        typeString = @"Attribute";
    } else if (self.isText) {
        typeString = @"Text";
    } else if (self.isCdata) {
        typeString = @"CData";
    } else if (self.isEntityRef) {
        typeString = @"Entity Reference";
    } else if (self.isEntity) {
        typeString = @"Entity";
    } else if (self.isProcessingInstruction) {
        typeString = @"Processing Instruction";
    } else if (self.isComment) {
        typeString = @"Comment";
    } else if (self.isDocument) {
        typeString = @"Document";
    } else if (self.isDoctype) {
        typeString = @"Doctype";
    } else if (self.isFragment) {
        typeString = @"Fragment";
    } else if (self.isNotation) {
        typeString = @"Notation";
    } else if (self.isWhitespace) {
        typeString = @"Whitespace";
    } else if (self.isSignificantWhitespace) {
        typeString = @"Significant Whitespace";
    } else if (self.isEndTag) {
        typeString = @"End Tag";
    } else if (self.isEndEntity) {
        typeString = @"End Entity";
    } else if (self.isXmlDecl) {
        typeString = @"XML Declaration";
    }
    return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, 0x00ab, self.value, 0x00bb];
}


- (NSString *)description {
    return [self debugDescription];
}

@synthesize none;
@synthesize startTag;
@synthesize attribute;
@synthesize text;
@synthesize cdata;
@synthesize entityRef;
@synthesize entity;
@synthesize processingInstruction;
@synthesize comment;
@synthesize document;
@synthesize doctype;
@synthesize fragment;
@synthesize notation;
@synthesize whitespace;
@synthesize significantWhitespace;
@synthesize endTag;
@synthesize endEntity;
@synthesize xmlDecl;
@synthesize stringValue;
@synthesize tokenType;
@synthesize value;
@end
