#import <AppKit/AppKit.h>

@class TMNode;
@class TMView;
@class TMPort;

@interface TMNodeView : NSView
{
	TMNode *_node;

	id _titleCell;
	NSMutableArray *_portCells;

	CGFloat _areaWidth;
	CGFloat _titleHeight;
	CGFloat _portHeight;

	id __contentView;
	id __contentButton;

	NSColor *_borderColor;
	BOOL _drawHilight;
}

- (id) initWithNode:(TMNode *)aNode;
- (void) setContentView:(NSView *)aView;
- (void) toggleContent:(id)sender;

//FIXME 
- (void) drawDropShadow;
@end

