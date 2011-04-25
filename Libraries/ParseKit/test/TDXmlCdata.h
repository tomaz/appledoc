//
//  PKXmlCdata.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/20/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "TDXmlTerminal.h"

@interface TDXmlCdata : TDXmlTerminal {

}
+ (id)cdata;
+ (id)cdataWithString:(NSString *)s;
@end
