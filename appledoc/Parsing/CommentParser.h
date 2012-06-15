//
//  CommentParser.h
//  appledoc
//
//  Created by Tomaz Kragelj on 6/13/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Helper class for simplifying parsing of comments.
 
 In essence this class handles appledoc comments and grouping of single line comments spread over multiple lines. Additionally it also strips any leading and trailing whitespace from individual lines. It also takes care of successive comments for detecting @name groups.
 
 What this class doesn't do is handling appledoc specific comments stuff such as processing text for cross references, detecting @ directives etc. In fact, in most cases the object to which the comment will belong to is not even known at the moment the comment is parsed - comments are usually located before the objects they describe (although not necessarily)! And some operations such as cross references detection are not even possible until all symbols are parsed! Furthermore, the comment should only be validated and processed if the application requires it, so processing it in advance may simply mean wasting user time for stuff that's not going to be needed.
 
 With that in mind, the comment parser is designed as highly reusable component that could be thrown in to any parsing loop as demonstrated in this (meta language-d to some extent) example:
 
 ```
 CommentParser *parser = [[CommentParser alloc] init];
 while (!<eof>) {
     PKToken *token = <get current token>;
     if (token.isComment) {
         if ([parser isAppledocComment:token.stringValue]) {
             [parser parseComment:token.stringValue line:token.location.y];
         }
         continue;
     }
     
     // register parsed comment(s) and clear parser - note that both group comment and comment may be nil!
     NSString *groupComment = parser.groupComment;
     NSString *comment = parser.comment;
     BOOL isInline = parser.isCommentInline;
     [parser reset];
     ...
 
     // parse non comment token
     ...
 }
 ```
 
 Above example relies on fact that you're using ParseKit for parsing (as it detects the comment automatically for us).
 */
@interface CommentParser : NSObject

- (BOOL)isAppledocComment:(NSString *)comment;
- (void)parseComment:(NSString *)comment line:(NSUInteger)line;
- (void)reset;

@property (nonatomic, strong, readonly) NSString *groupComment;
@property (nonatomic, strong, readonly) NSString *comment;
@property (nonatomic, assign, readonly) BOOL isCommentInline;

@end
