//
//  CommentNamedArgumentInfo.h
//  appledoc
//
//  Created by Tomaz Kragelj on 31.10.12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Handles data for comment named arguments (parameters, exceptions).
 */
@interface CommentNamedArgumentInfo : NSObject

@property (nonatomic, copy) NSString *argumentName;
@property (nonatomic, copy) NSMutableArray *argumentComponents; // CommentComponentInfo

@end
