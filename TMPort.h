#import <Foundation/Foundation.h>

@class TMNode;

@interface TMPort : NSObject
{
	TMNode *__owner;
	TMPort *__pair;
}

- (id) initWithNode:(TMNode *)aNode;
- (void) connect:(TMPort *)aPair;
- (void) disconnect;
@end

