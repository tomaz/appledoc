#import <Foundation/Foundation.h>
#import "CDRExampleParent.h"

@protocol CDRExampleReporter;

typedef void (^CDRSpecBlock)(void);

enum CDRExampleState {
    CDRExampleStateIncomplete = 0x00,
    CDRExampleStateSkipped = 0x01,
    CDRExampleStatePassed = 0x03,
    CDRExampleStatePending = 0x07,
    CDRExampleStateFailed = 0x0F,
    CDRExampleStateError = 0x1F
};
typedef enum CDRExampleState CDRExampleState;

@interface CDRExampleBase : NSObject {
  NSString *text_;
  id<CDRExampleParent> parent_;
  BOOL focused_;
}

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, assign) id<CDRExampleParent> parent;
@property (nonatomic, assign, getter=isFocused) BOOL focused;

- (id)initWithText:(NSString *)text;

- (void)run;
- (BOOL)shouldRun;

- (BOOL)hasChildren;
- (BOOL)hasFocusedExamples;

- (NSString *)message;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;
@end

@interface CDRExampleBase (RunReporting)
- (CDRExampleState)state;
- (float)progress;
@end
