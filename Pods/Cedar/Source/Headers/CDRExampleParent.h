#import <Foundation/Foundation.h>

@protocol CDRExampleParent

- (BOOL)shouldRun;

- (void)setUp;
- (void)tearDown;

@optional
- (BOOL)hasFullText;
- (NSString *)fullText;
- (NSMutableArray *)fullTextInPieces;

@end
