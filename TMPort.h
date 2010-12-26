#import <Foundation/Foundation.h>

@class TMNode;

@interface TMPort : NSObject
{
	TMNode *__node;
	TMPort *__pair;
}

- (id) initWithNode:(TMNode *)aNode;
- (void) connect:(TMPort *)aPair;
- (void) disconnect;
@end


@interface TMImport : TMPort
@end

@interface TMExport : TMPort
@end
