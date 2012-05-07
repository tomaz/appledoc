//
//  StateBase.m
//  appledoc
//
//  Created by Tomaž Kragelj on 5/6/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

#import "StateBase.h"

@implementation StateBase

@synthesize currentContext;

- (void)didBecomeCurrentStateForContext:(id)context {
	self.currentContext = context;
}

- (void)willResignCurrentStateForContext:(id)context {
	self.currentContext = nil;
}

@end

#pragma mark - 

@implementation BlockStateBase

@synthesize didBecomeCurrentStateBlock;
@synthesize willResignCurrentStateBlock;

- (void)didBecomeCurrentStateForContext:(id)context {
	[super didBecomeCurrentStateForContext:context];
	if (self.didBecomeCurrentStateBlock) self.didBecomeCurrentStateBlock(self, context);
}

- (void)willResignCurrentStateForContext:(id)context {
	[super willResignCurrentStateForContext:context];
	if (self.willResignCurrentStateBlock) self.willResignCurrentStateBlock(self, context);
}

@end

#pragma mark - 

@implementation ContextBase

@synthesize currentState;

- (void)changeStateTo:(StateBase *)state {
	[self.currentState willResignCurrentStateForContext:self];
	self.currentState = state;
	[self.currentState didBecomeCurrentStateForContext:self];
}

@end