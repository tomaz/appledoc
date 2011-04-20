//
//  SRGSParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/15/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <ParseKit/ParseKit.h>

@interface SRGSParser : PKSequence {
    PKCollectionParser *selfIdentHeader;
    PKCollectionParser *ruleName;
    PKCollectionParser *tagFormat;
    PKCollectionParser *lexiconURI;
    PKCollectionParser *weight;
    PKCollectionParser *repeat;
    PKCollectionParser *probability;
    PKCollectionParser *externalRuleRef;
    PKCollectionParser *token;
    PKCollectionParser *languageAttachment;
    PKCollectionParser *tag;
    PKCollectionParser *grammar;
    PKCollectionParser *declaration;
    PKCollectionParser *baseDecl;
    PKCollectionParser *languageDecl;
    PKCollectionParser *modeDecl;
    PKCollectionParser *rootRuleDecl;
    PKCollectionParser *tagFormatDecl;
    PKCollectionParser *lexiconDecl;
    PKCollectionParser *metaDecl;
    PKCollectionParser *tagDecl;
    PKCollectionParser *ruleDefinition;
    PKCollectionParser *scope;
    PKCollectionParser *ruleExpansion;
    PKCollectionParser *ruleAlternative;
    PKCollectionParser *sequenceElement;
    PKCollectionParser *subexpansion;
    PKCollectionParser *ruleRef;
    PKCollectionParser *localRuleRef;
    PKCollectionParser *specialRuleRef;
    PKCollectionParser *repeatOperator;
    
    PKCollectionParser *baseURI;
    PKCollectionParser *languageCode;
    PKCollectionParser *ABNF_URI;
    PKCollectionParser *ABNF_URI_with_Media_Type;
}
- (id)parse:(NSString *)s;
- (PKAssembly *)assemblyWithString:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *selfIdentHeader;
@property (nonatomic, retain) PKCollectionParser *ruleName;
@property (nonatomic, retain) PKCollectionParser *tagFormat;
@property (nonatomic, retain) PKCollectionParser *lexiconURI;
@property (nonatomic, retain) PKCollectionParser *weight;
@property (nonatomic, retain) PKCollectionParser *repeat;
@property (nonatomic, retain) PKCollectionParser *probability;
@property (nonatomic, retain) PKCollectionParser *externalRuleRef;
@property (nonatomic, retain) PKCollectionParser *token;
@property (nonatomic, retain) PKCollectionParser *languageAttachment;
@property (nonatomic, retain) PKCollectionParser *tag;
@property (nonatomic, retain) PKCollectionParser *grammar;
@property (nonatomic, retain) PKCollectionParser *declaration;
@property (nonatomic, retain) PKCollectionParser *baseDecl;
@property (nonatomic, retain) PKCollectionParser *languageDecl;
@property (nonatomic, retain) PKCollectionParser *modeDecl;
@property (nonatomic, retain) PKCollectionParser *rootRuleDecl;
@property (nonatomic, retain) PKCollectionParser *tagFormatDecl;
@property (nonatomic, retain) PKCollectionParser *lexiconDecl;
@property (nonatomic, retain) PKCollectionParser *metaDecl;
@property (nonatomic, retain) PKCollectionParser *tagDecl;
@property (nonatomic, retain) PKCollectionParser *ruleDefinition;
@property (nonatomic, retain) PKCollectionParser *scope;
@property (nonatomic, retain) PKCollectionParser *ruleExpansion;
@property (nonatomic, retain) PKCollectionParser *ruleAlternative;
@property (nonatomic, retain) PKCollectionParser *sequenceElement;
@property (nonatomic, retain) PKCollectionParser *subexpansion;
@property (nonatomic, retain) PKCollectionParser *ruleRef;
@property (nonatomic, retain) PKCollectionParser *localRuleRef;
@property (nonatomic, retain) PKCollectionParser *specialRuleRef;
@property (nonatomic, retain) PKCollectionParser *repeatOperator;

@property (nonatomic, retain) PKCollectionParser *baseURI;
@property (nonatomic, retain) PKCollectionParser *languageCode;
@property (nonatomic, retain) PKCollectionParser *ABNF_URI;
@property (nonatomic, retain) PKCollectionParser *ABNF_URI_with_Media_Type;
@end
