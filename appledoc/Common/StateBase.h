//
//  StateBase.h
//  appledoc
//
//  Created by Tomaž Kragelj on 5/6/12.
//  Copyright (c) 2012 Tomaz Kragelj. All rights reserved.
//

/** Defines base class for a state.
 
 This implementation provides just bare functionality of a state - whatever is needed to connect it with its parent ContextBase object. Each concrete state would require concrete derived class specialized for the required behavior.
 
 @warning **Note:** Note that while this class is bare minimum, it implements the following:
 
 - When didBecomeCurrentStateForContext: message is sent, the context passed as the argument is assigned to currentContext property.
 - When willResignCurrentStateForContext: message is sent, currentContext is set to `nil`.
 
 If for whatever reason your subclass doesn't want this behavior, it should not use base implementations.
 */
@interface StateBase : NSObject

- (void)didBecomeCurrentStateForContext:(id)context;
- (void)willResignCurrentStateForContext:(id)context;

@property (nonatomic, weak) id currentContext;

@end

#pragma mark - 

typedef void(^StateBaseCallbackBlock)(id state, id context);

/** Defines block based state.
 
 This is particulary useful for cases where you don't want to use inheritance, but would rather rely on delegation to implement concrete states. This may reduce clutter for example.
 
 @warning **Note:** The implementation simply overrides notifications for ContextBase, calls super implementation and then invokes the corresponding blocks. You can still subclass and implement your own custom behavior on top of this.
 */
@interface BlockStateBase : StateBase

@property (nonatomic, copy) StateBaseCallbackBlock didBecomeCurrentStateBlock;
@property (nonatomic, copy) StateBaseCallbackBlock willResignCurrentStateBlock;

@end

#pragma mark - 

/** Defines base class for a state context.
 
 The context is an object that handles states and acts as the madiator between application objects and states. The class is designed so that it can be used either through inheritance - as a base class for concrete implementation - or through composition - as instance variable or property of another class. See GOF state pattern for more details.
 
 @warning **Note:** Note that you have two options when changing state: in most cases, you'd use changeStateTo: which will notify current state about going out and new state about becoming current. However if your concrete implementation requires cases where these notifications shouldn't be sent when changing state (in most cases during initial context setup), you can directly change the state through currentState property.
 */
@interface ContextBase : NSObject

- (void)changeStateTo:(StateBase *)state;

@property (nonatomic, strong) id currentState;

@end
