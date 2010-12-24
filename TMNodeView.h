#import <AppKit/AppKit.h>

@class TMNode;
@class TMView;

@interface TMNodeView : NSView
{
	TMNode *_node;
	id _contentView;
	id _titleCell;
}

- (id) initWithNode:(TMNode *)aNode;
- (void) setContentView:(NSView *)aView;
@end
