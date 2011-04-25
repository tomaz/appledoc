//
//  PKXmlNotation.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTerminal.h"

@interface TDXmlNotation : TDXmlTerminal {

}
+ (id)notation;
+ (id)notationWithString:(NSString *)s;
@end
