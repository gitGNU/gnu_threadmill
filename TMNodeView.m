#import "TMNodeView.h"

@interface TMNodeView (Private)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
@end

@implementation TMNodeView (Private)
- (void) _recalculateFrame
{
}

- (void) _setNode:(TMNode*)aNode
{
	ASSIGN(_node, aNode);
	[self _recalculateFrame];
	[self setNeedsDisplay:YES];
}

@end

@implementation TMNodeView

- (id) initWithNode:(TMNode *)aNode
{
	[self _setNode:aNode];

	return [self initWithFrame:NSMakeRect(0,0,200,300)]; //FIXME
}

- (void) dealloc
{
	DESTROY(_node);
	[super dealloc];
}

- (void) drawRect:(NSRect)r
{
	[[NSColor redColor] set];
	NSRectFill(r);
}

- (void) setContentView:(NSView *)aView
{
	if (aView == nil)
		[self removeSubview:_contentView];
	else if (_contentView == nil)
		[self addSubview:aView];
	else [self replaceSubview:_contentView with:aView];

	_contentView = aView;
}

- (void) mouseDown:(NSEvent *)anEvent
{
	NSPoint p = [self convertPointFromBase:[anEvent locationInWindow]];

}

@end

