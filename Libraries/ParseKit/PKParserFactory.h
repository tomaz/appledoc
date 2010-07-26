//
//  PKParserFactory.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKGrammarParser;
@class PKToken;
@class PKTokenizer;
@class PKParser;
@class PKCollectionParser;

void PKReleaseSubparserTree(PKParser *p);

typedef enum {
    PKParserFactoryAssemblerSettingBehaviorOnAll        = 1 << 1, // Default
    PKParserFactoryAssemblerSettingBehaviorOnTerminals  = 1 << 2,
    PKParserFactoryAssemblerSettingBehaviorOnExplicit   = 1 << 3,
    PKParserFactoryAssemblerSettingBehaviorOnNone       = 1 << 4
} PKParserFactoryAssemblerSettingBehavior;

@interface PKParserFactory : NSObject {
    PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
    PKGrammarParser *grammarParser;
    id assembler;
    id preassembler;
    NSMutableDictionary *parserTokensTable;
    NSMutableDictionary *parserClassTable;
    NSMutableDictionary *selectorTable;
    PKToken *equals;
    PKToken *curly;
    PKToken *paren;
    BOOL isGatheringClasses;
}

+ (PKParserFactory *)factory;

- (PKParser *)parserFromGrammar:(NSString *)s assembler:(id)a;
- (PKParser *)parserFromGrammar:(NSString *)s assembler:(id)a preassembler:(id)pa;

- (PKCollectionParser *)exprParser;

@property (nonatomic) PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
@end
