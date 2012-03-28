//
//  ObjectiveCParserState.h
//  appledoc
//
//  Created by Tomaž Kragelj on 3/20/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "Objects.h"
#import "Store.h"
#import "ObjectiveCParser.h"
#import "TokensStream.h"

/** The base class for handling individual pieces of Objective C on behalf of ObjectiveCParser.
 
 The intention behind splitting parsing code into smaller classes is more structured and thus readable and reusable code. Parsing workflow is to send `parseStream:forParser:store:` message to a state instance to let the state start parsing from current stream position. State parsing is usually composed of testing the given stream for known objects, starting at stream's current position. If known object is found, all its tokens are consumed and data is registered to the given Store. If necessary, state can change to other states for doing concrete parsing of various sub-components. When the state is done, it switches back to previous state. This class is tighlty integrated with ObjectiveCParser and relies on it to continuously send `parseStream:forParser:store:` requests until the EOF is reached.
 
 When designing concrete subclasses, keep in mind that they should generally be state-less; each subclass parsing may be invoked at any time - whenever current token stream matches (or seems to match) particular object. Once the subclass finishes, it should consume all parsed tokens and change state again or revert to previous one. To keep states as context agnostic as possible, ObjectiveCParser defines states stack; to change to a new state, simply push the new state to the stack via [ObjectiveCParser pushState:] and to revert to previous state, send [ObjectiveCParser popState] to the parser object. ObjectiveCParser also defines all available states as properties.
 */
@interface ObjectiveCParserState : NSObject

- (NSUInteger)parseStream:(TokensStream *)stream forParser:(ObjectiveCParser *)parser store:(Store *)store;

@end

#pragma mark - 

/** Helper methods for concrete subclasses.
 
 Do not use these from elsewhere!
 */
@interface ObjectiveCParserState (SubclassPrivateAPI)
- (NSUInteger)lookAheadStream:(TokensStream *)stream block:(void(^)(PKToken *token, NSUInteger lookahead, BOOL *stop))handler;
- (NSUInteger)matchStream:(TokensStream *)stream until:(id)end block:(void(^)(PKToken *token, NSUInteger lookahead))handler;
- (NSUInteger)matchStream:(TokensStream *)stream start:(NSString *)start end:(NSString *)end block:(void(^)(PKToken *token, NSUInteger lookahead))handler;
@end
