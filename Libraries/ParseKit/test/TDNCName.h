//
//  PKNCName.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 8/16/08.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "PKTerminal.h"
#import "PKToken.h"

extern const NSInteger PKTokenTypeNCName;

@interface PKToken (NCNameAdditions)
@property (readonly, getter=isNCName) BOOL NCName;
@end

@interface TDNCName : PKTerminal {

}
+ (id)NCName;
@end
