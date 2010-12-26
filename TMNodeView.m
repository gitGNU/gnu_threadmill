#import "TMNodeView.h"
#import "TMPortCell.h"
#import "TMNode.h"

#define MININUM_TITLE_HEIGHT 20
#define MININUM_PORT_HEIGHT 15
#define BORDER_SIZE 30
#define BORDER_LINE_SIZE 3

NSDate * __distFuture;

@interface TMNodeView (Private)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
@end

@implementation TMNodeView (Private)
- (void) _recalculateFrame
{

	/* calculate new title size */
	NSRect contentRect = __contentView != nil && [__contentView isHidden] ? NSZeroRect : [__contentView frame];

	{
		NSSize titleSize = [_titleCell cellSize];

		_titleHeight = titleSize.height;
		_titleHeight = MAX(_titleHeight, MININUM_TITLE_HEIGHT);
		_areaWidth = MAX(titleSize.width + _titleHeight, NSWidth(contentRect)); /* + _titleHeight for the button area */
	}

	/* expand for port name as necessary */
	_portHeight = 0;
	NSEnumerator *en = [_portCells objectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		NSSize portSize = [port cellSize];
		_areaWidth = MAX(_areaWidth, portSize.width);
		_portHeight += MAX(portSize.height, MININUM_PORT_HEIGHT);
	}


	/* calculate new frame size */
	NSRect oldFrame = [self frame];
	NSRect newFrame;

	newFrame.size.height = 2 * BORDER_SIZE + _titleHeight + NSHeight(contentRect) + _portHeight - BORDER_LINE_SIZE;
	newFrame.size.width = 2 * BORDER_SIZE + _areaWidth;
	newFrame.origin.x = NSMinX(oldFrame);
	newFrame.origin.y = NSMaxY(oldFrame) - NSHeight(newFrame);

	[self setFrame:newFrame];

	/* adjust content location */
	NSRect bounds = [self bounds];
	contentRect.origin = NSMakePoint(BORDER_SIZE + (_areaWidth / 2) - (NSWidth(contentRect) / 2), NSMaxY(bounds) - _titleHeight - BORDER_SIZE - NSHeight(contentRect));

	if (__contentView == nil)
	{
		[__contentButton setHidden:YES];
	}
	else [__contentButton setHidden:NO];

	if (__contentView != nil && [__contentView isHidden])
	{
		[__contentButton setImage:[NSImage imageNamed:@"common_ArrowDown.tiff"]];
	}
	else
	{
		[__contentButton setImage:[NSImage imageNamed:@"common_ArrowUp.tiff"]];
	}

	[__contentView setFrameOrigin:contentRect.origin];
	[__contentButton setFrame:NSMakeRect(BORDER_SIZE, NSHeight(newFrame) - BORDER_SIZE - _titleHeight , _titleHeight, _titleHeight)];

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

	[self initWithFrame:NSMakeRect(0, 0, 200, 300)]; //FIXME

	__contentButton = AUTORELEASE([NSButton new]);
	[__contentButton setTarget:self];
	[__contentButton setAction:@selector(toggleContent:)];
	[self addSubview:__contentButton];

	[self _setNode:aNode];

	_portCells = [[NSMutableArray alloc] init];

	/* imports */

	NSEnumerator *en;
	NSString *aName;
	en = [[[_node importNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectEnumerator]; // FIXME, considering exposing TMPort, what could be so bad about that?
	while ((aName = [en nextObject]))
	{
		[_portCells addObject:AUTORELEASE([[TMImportCell alloc] initWithName:aName])];
	}

	/* exports */

	en = [[[_node exportNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectEnumerator]; // FIXME, considering exposing TMPort, what could be so bad about that?
	while ((aName = [en nextObject]))
	{
		[_portCells addObject:AUTORELEASE([[TMExportCell alloc] initWithName:aName])];
	}



	return self;
}

- (void) dealloc
{
	DESTROY(_node);
	DESTROY(_titleCell);
	DESTROY(_portCells);
	[super dealloc];
}

- (void) drawRect:(NSRect)r
{
	NSRect bounds = [self bounds];

	/* fill body */
	[[NSColor blackColor] set];
	NSRectFill(NSInsetRect(bounds, BORDER_SIZE - BORDER_LINE_SIZE, BORDER_SIZE - BORDER_LINE_SIZE));

	[[NSColor windowBackgroundColor] set];
	NSRectFill(NSInsetRect(bounds, BORDER_SIZE, BORDER_SIZE));

	/* draw title */
	NSRect textRect;
	textRect.origin = NSMakePoint(BORDER_SIZE + _titleHeight, NSMaxY(bounds) - _titleHeight - BORDER_SIZE);
       	textRect.size = NSMakeSize(_areaWidth - _titleHeight, _titleHeight);
	[[NSColor whiteColor] set];
	NSRectFill(textRect);
	[_titleCell drawWithFrame:textRect inView:self];


	textRect.origin = NSMakePoint(BORDER_SIZE, BORDER_SIZE - BORDER_LINE_SIZE);
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		textRect.size = [port cellSize];
		textRect.size.height = MAX(NSHeight(textRect), MININUM_PORT_HEIGHT);
		textRect.size.width = MAX(NSWidth(textRect), _areaWidth);


		[port drawWithFrame:textRect inView:self];
		textRect.origin.y += NSHeight(textRect);
	}
}

- (void) setContentView:(NSView *)aView
{

	if (aView == nil)
		[self removeSubview:__contentView];
	else if (__contentView == nil)
		[self addSubview:aView];
	else [self replaceSubview:__contentView with:aView];

	__contentView = aView;

	[self _recalculateFrame];
}

- (void) toggleContent:(id)sender
{
	[__contentView setHidden:![__contentView isHidden]];

	[self _recalculateFrame];

}

- (void) mouseDown:(NSEvent *)anEvent
{
	NSRect bounds = [self bounds];

	NSPoint origin = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
	NSRect originFrame = [self frame];

	/* display mouse down here */

	/* track frame movement */
	if (NSPointInRect([self convertPointFromBase:[anEvent locationInWindow]], NSMakeRect(0, NSMaxY(bounds) - _titleHeight - BORDER_SIZE, NSWidth(bounds), _titleHeight)))
	while (YES)
	{
		anEvent = [NSApp nextEventMatchingMask:
					NSLeftMouseUpMask |
					NSLeftMouseDraggedMask |
					NSMouseMovedMask
				untilDate:__distFuture
				inMode:NSEventTrackingRunLoopMode
				dequeue:YES];

		NSEventType eventType = [anEvent type];

		if (eventType == NSLeftMouseUp)
			break;

		NSPoint p = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
		p.x = NSMinX(originFrame) + p.x - origin.x;
		p.y = NSMinY(originFrame) + p.y - origin.y;

		NSRect oldFrame = [self frame];
		[self setFrameOrigin:p];

		[self setNeedsDisplay:YES];
		[[self superview] setNeedsDisplayInRect:oldFrame];

	}

}

@end

