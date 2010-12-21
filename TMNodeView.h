#import <AppKit/AppKit.h>

@class TMNode;

@interface TMNodeView : NSView
{
	TMNode *_node;
}

- (id) initWithNode:(TMNode *)aNode;
@end
