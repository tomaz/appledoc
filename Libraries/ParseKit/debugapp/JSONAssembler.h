//
//  JSONAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKToken;

@interface JSONAssembler : NSObject {
    NSMutableAttributedString *displayString;
    id defaultAttrs;
    id objectAttrs;
    id arrayAttrs;
    id propertyNameAttrs;
    id valueAttrs;
    id constantAttrs;
    
    PKToken *comma;
    PKToken *curly;
    PKToken *bracket;
}
@property (retain) NSMutableAttributedString *displayString;
@property (retain) id defaultAttrs;
@property (retain) id objectAttrs;
@property (retain) id arrayAttrs;
@property (retain) id propertyNameAttrs;
@property (retain) id valueAttrs;
@property (retain) id constantAttrs;
@property (retain) PKToken *comma;
@property (retain) PKToken *curly;
@property (retain) PKToken *bracket;
@end
