//
//  ObjectiveCParser.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "ParserTask.h"

@class PKTokenizer;
@class ObjectiveCParserState;

/** Concrete implementation of ParserTask for parsing Objective C source code.
 */
@interface ObjectiveCParser : ParserTask

@property (nonatomic, strong) PKTokenizer *tokenizer;

@end

#pragma mark - 

/** Defines API private for using within ObjectiveCParserState.
 
 This shouldn't be used from outside!
 */
@interface ObjectiveCParser (StatePrivateAPI)
- (void)pushState:(ObjectiveCParserState *)state;
- (void)popState;
@property (nonatomic, strong) ObjectiveCParserState *fileState;
@property (nonatomic, strong) ObjectiveCParserState *interfaceState;
@property (nonatomic, strong) ObjectiveCParserState *propertyState;
@property (nonatomic, strong) ObjectiveCParserState *methodState;
@property (nonatomic, strong) ObjectiveCParserState *pragmaMarkState;
@property (nonatomic, strong) ObjectiveCParserState *enumState;
@property (nonatomic, strong) ObjectiveCParserState *structState;
@end
