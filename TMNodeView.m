#import "TMNodeView.h"

#define TITLE_HEIGHT 20
#define BORDER_SIZE 3
#define PORT_SIZE 15

NSDate * __distFuture;

@interface TMNodeView (Private)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
@end

@implementation TMNodeView (Private)
- (void) _recalculateFrame
{
	if (_contentView == nil)
	{
		return;
		//FIXME
	}

	NSRect contentRect = [_contentView frame];

	NSRect oldFrame = [self frame];
	NSRect newFrame;
	newFrame.size.height = 2 * BORDER_SIZE + TITLE_HEIGHT + NSHeight(contentRect); // + port sizes
	newFrame.size.width = 2 * BORDER_SIZE + NSWidth(contentRect); // FIXME, consider title and port names' string sizes
	newFrame.origin.x = NSMinX(oldFrame);
	newFrame.origin.y = NSMaxY(oldFrame) - NSHeight(newFrame);

	[self setFrame:newFrame];

	NSRect bounds = [self bounds];
	contentRect.origin = NSMakePoint(BORDER_SIZE, NSMaxY(bounds) - TITLE_HEIGHT - BORDER_SIZE - NSHeight(contentRect));

	[_contentView setFrameOrigin:contentRect.origin];
	[self setNeedsDisplay:YES];
}

- (void) _setNode:(TMNode*)aNode
{
	ASSIGN(_node, aNode);
	[_titleCell setTitle:[_node name]];
	[self _recalculateFrame];

	[self setNeedsDisplay:YES];
}

@end

@implementation TMNodeView

+ (void) initialize
{
	__distFuture = [NSDate distantFuture];
}

- (id) initWithNode:(TMNode *)aNode
{
	ASSIGN(_titleCell, [[NSCell alloc] initTextCell:@"Node"]);
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
	NSRect bounds = [self bounds];

	/* fill body */
	[[NSColor blackColor] set];
	NSRectFill(r);

	[[NSColor grayColor] set];
	NSRectFill(NSInsetRect(bounds,BORDER_SIZE,BORDER_SIZE));

	/* draw title */
	NSRect titleRect = NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - TITLE_HEIGHT - BORDER_SIZE, NSWidth(bounds) - 2 * BORDER_SIZE, TITLE_HEIGHT);
	[[NSColor whiteColor] set];
	NSRectFill(titleRect);
	[_titleCell drawWithFrame:titleRect inView: self];


}

- (void) setContentView:(NSView *)aView
{
	NSRect contentRect;


	if (aView == nil)
		[self removeSubview:_contentView];
	else if (_contentView == nil)
		[self addSubview:aView];
	else [self replaceSubview:_contentView with:aView];

	_contentView = aView;

	[self _recalculateFrame];
}

- (void) mouseDown:(NSEvent *)anEvent
{
	NSRect bounds = [self bounds];

	NSPoint origin = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
	NSRect originFrame = [self frame];

	/* display mouse down here */

	/* track frame movement */
	if (NSPointInRect([self convertPointFromBase:[anEvent locationInWindow]],NSMakeRect(0, NSMaxY(bounds) - TITLE_HEIGHT - BORDER_SIZE, NSWidth(bounds), TITLE_HEIGHT)))
	while (YES)
	{
		anEvent = [NSApp nextEventMatchingMask:
					NSLeftMouseUpMask |
					NSLeftMouseDraggedMask |
					NSMouseMovedMask
				untilDate: __distFuture
				inMode: NSEventTrackingRunLoopMode
				dequeue: YES];

		NSEventType eventType = [anEvent type];


		if (eventType == NSLeftMouseUp)
			break;


		NSPoint p = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
		p.x = NSMinX(originFrame) + p.x - origin.x;
		p.y = NSMinY(originFrame) + p.y - origin.y;

		NSRect oldFrame = [self frame];
		[self setFrameOrigin:p];

		[self setNeedsDisplay:YES];
		[[self superview] setNeedsDisplayInRect:NSInsetRect(oldFrame,-20,-20)];

	}

}

@end

