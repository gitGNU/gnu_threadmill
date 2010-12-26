#import "TMNodeView.h"
#import "TMPortCell.h"
#import "TMNode.h"
#import "TMDefs.h"

NSDate * __distFuture;
NSString * TMPasteboardTypeLink = @"TMPasteboardTypeLink";

@interface TMNodeView (Private)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
@end

@implementation TMNodeView (Private)
- (void) _recalculateFrame
{
	BOOL contentHidden = __contentView == nil ? YES : [__contentView isHidden];

	/* calculate new title size */
	NSRect contentRect = contentHidden ? NSZeroRect : [__contentView frame];

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

	newFrame.size.height = 2 * BORDER_SIZE + _titleHeight + _portHeight;
	if (contentHidden)
		newFrame.size.height -= BORDER_LINE_SIZE;
	else
		newFrame.size.height += NSHeight(contentRect);
	newFrame.size.width = 2 * BORDER_SIZE + _areaWidth;
	newFrame.origin.x = NSMinX(oldFrame);
	newFrame.origin.y = NSMaxY(oldFrame) - NSHeight(newFrame);

	[self setFrame:newFrame];

	/* adjust content location */
	NSRect bounds = [self bounds];

	/* set folding button */
	if (__contentView == nil)
	{
		[__contentButton setHidden:YES];
	}
	else [__contentButton setHidden:NO];

	if (__contentView != nil && contentHidden)
	{
		[__contentButton setImage:[NSImage imageNamed:@"common_ArrowDown.tiff"]];
	}
	else
	{
		[__contentButton setImage:[NSImage imageNamed:@"common_ArrowUp.tiff"]];
	}
	[__contentButton setFrame:NSMakeRect(BORDER_SIZE, NSHeight(newFrame) - BORDER_SIZE - _titleHeight , _titleHeight, _titleHeight)];


	if (!contentHidden)
	{
		contentRect.origin = NSMakePoint(BORDER_SIZE + (_areaWidth / 2) - (NSWidth(contentRect) / 2), NSMaxY(bounds) - _titleHeight - BORDER_SIZE - NSHeight(contentRect) - BORDER_LINE_SIZE);
		[__contentView setFrameOrigin:contentRect.origin];
	}

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
	ASSIGN(_borderColor, [NSColor blackColor]);

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

	/* register */
	[self registerForDraggedTypes:[NSArray arrayWithObject:TMPasteboardTypeLink]];

	return self;
}

- (void) dealloc
{
	DESTROY(_node);
	DESTROY(_titleCell);
	DESTROY(_portCells);
	DESTROY(_borderColor);
	[super dealloc];
}

- (void) drawDropShadow
{
	if (_drawHilight)
	{
		NSGraphicsContext *ctxt=GSCurrentContext();

		[[NSColor cyanColor] set];
		NSRect r = NSInsetRect([self bounds],BORDER_SIZE ,BORDER_SIZE );
		DPSsetlinejoin(ctxt, 1);

		DPSsetalpha(ctxt, 0.1);
		DPSsetlinewidth(ctxt, 16);
		DPSsetrgbcolor(ctxt,0.0,0.5,0.8);
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));

		DPSsetlinewidth(ctxt, 12);
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));

		DPSsetlinewidth(ctxt, 10);
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));
	}
}

- (void) drawRect:(NSRect)r
{
	NSRect bounds = [self bounds];

	[self drawDropShadow];

	/* fill body */
	[_borderColor set];
	NSRectFill(NSMakeRect(BORDER_SIZE - BORDER_LINE_SIZE, 
				BORDER_SIZE - BORDER_LINE_SIZE + _portHeight,
				NSWidth(bounds) - BORDER_SIZE * 2 + BORDER_LINE_SIZE * 2,
				NSHeight(bounds) - _portHeight - 2 * BORDER_SIZE + 2 * BORDER_LINE_SIZE));


	[[NSColor windowBackgroundColor] set];
	NSRectFill(NSMakeRect(BORDER_SIZE, 
				BORDER_SIZE - BORDER_LINE_SIZE + _portHeight,
				NSWidth(bounds) - BORDER_SIZE * 2,
				NSHeight(bounds) - _portHeight - 2 * BORDER_SIZE + BORDER_LINE_SIZE));

	/* draw title */
	NSRect textRect;
	textRect.origin = NSMakePoint(BORDER_SIZE + _titleHeight, NSMaxY(bounds) - _titleHeight - BORDER_SIZE);
       	textRect.size = NSMakeSize(_areaWidth - _titleHeight, _titleHeight);
	[[NSColor whiteColor] set];
	NSRectFill(textRect);
	[_titleCell drawWithFrame:textRect inView:self];

	[_borderColor set];
	NSRectFill(NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - _titleHeight - BORDER_SIZE - BORDER_LINE_SIZE,
				_areaWidth, BORDER_LINE_SIZE
				));


	textRect.origin = NSMakePoint(BORDER_SIZE - BORDER_LINE_SIZE, BORDER_SIZE - BORDER_LINE_SIZE*1.5);
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		textRect.size = [port cellSize];
		textRect.size.height = MAX(NSHeight(textRect), MININUM_PORT_HEIGHT);
		textRect.size.width = MAX(NSWidth(textRect), _areaWidth) + 1.5 * BORDER_LINE_SIZE;

		[port setBorderColor:_borderColor];
		[port drawWithFrame:textRect inView:self];

		textRect.origin.y += NSHeight(textRect);
	}
}

- (NSView*) hitTest: (NSPoint)aPoint
{
	NSView *retView = [super hitTest:aPoint];

	if (retView == self)
	{
		aPoint = [self convertPoint:aPoint fromView:[self superview]];

		NSRect portRect;
		portRect.origin = NSMakePoint(BORDER_SIZE - BORDER_LINE_SIZE, BORDER_SIZE - BORDER_LINE_SIZE*1.5);
		NSEnumerator *en = [_portCells reverseObjectEnumerator];
		TMPortCell *port;
		//FIXME this should be cached
		while ((port = [en nextObject]))
		{
			portRect.size = [port cellSize];
			portRect.size.height = MAX(NSHeight(portRect), MININUM_PORT_HEIGHT);
			portRect.size.width = MAX(NSWidth(portRect), _areaWidth) + 1.5 * BORDER_LINE_SIZE;

			if (NSPointInRect(aPoint, portRect))
			{
				return self;
			}

			portRect.origin.y += NSHeight(portRect);
		}
	}

	return retView;
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

- (void) setBorderColor:(NSColor *)aColor
{
	ASSIGN(_borderColor, aColor);
	[self setNeedsDisplay:YES];
}

- (void) setDrawHighlight:(BOOL)shouldDrawHighlight
{
	_drawHilight = shouldDrawHighlight;
	[self setNeedsDisplay:YES];
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)becomeFirstResponder
{
	[self setDrawHighlight:YES];
	return YES;
}

- (BOOL)resignFirstResponder
{
	[self setDrawHighlight:NO];
	return YES;
}

- (void) mouseDown:(NSEvent *)anEvent
{
	NSRect bounds = [self bounds];

	NSPoint frameDragOrigin = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
	NSPoint mouseDownPoint = [self convertPointFromBase:[anEvent locationInWindow]];
	NSRect originFrame = [self frame];

	/* display mouse down here */

	NSColor *oldBorderColor = nil;
	ASSIGN(oldBorderColor, _borderColor);
	AUTORELEASE(oldBorderColor);


	/* track frame movement */
	if (NSPointInRect(mouseDownPoint, NSMakeRect(0,
					NSMaxY(bounds) - _titleHeight - BORDER_SIZE,
					NSWidth(bounds),
					_titleHeight)))
	{
		BOOL setDragColor = YES;
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

			if (setDragColor)
			{
				[self setBorderColor:[NSColor cyanColor]];
				setDragColor = NO;
			}

			NSPoint p = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
			p.x = NSMinX(originFrame) + p.x - frameDragOrigin.x;
			p.y = NSMinY(originFrame) + p.y - frameDragOrigin.y;

			NSRect oldFrame = [self frame];
			[self setFrameOrigin:p];

			[self setNeedsDisplay:YES];
			[[self superview] setNeedsDisplayInRect:oldFrame];

		}

		[self setBorderColor:oldBorderColor];
	}
	/* track port dragging */
	else
	{
		NSRect portRect;
		portRect.origin = NSMakePoint(BORDER_SIZE - BORDER_LINE_SIZE, BORDER_SIZE - BORDER_LINE_SIZE*1.5);
		NSEnumerator *en = [_portCells reverseObjectEnumerator];
		TMPortCell *port;
		//FIXME this should be cached
		while ((port = [en nextObject]))
		{
			portRect.size = [port cellSize];
			portRect.size.height = MAX(NSHeight(portRect), MININUM_PORT_HEIGHT);
			portRect.size.width = MAX(NSWidth(portRect), _areaWidth) + 1.5 * BORDER_LINE_SIZE;

			[port drawWithFrame:portRect inView:self];
			if (NSPointInRect(mouseDownPoint, portRect))
			{
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

					/*
					NSPoint p = [[self superview] convertPointFromBase:[anEvent locationInWindow]];
					p.x = NSMinX(originFrame) + p.x - frameDragOrigin.x;
					p.y = NSMinY(originFrame) + p.y - frameDragOrigin.y;

					NSRect oldFrame = [self frame];
					[self setFrameOrigin:p];

					[self setNeedsDisplay:YES];
					[[self superview] setNeedsDisplayInRect:oldFrame];
					*/

					 NSPasteboard *pb;
					 pb = [NSPasteboard pasteboardWithName:NSDragPboard];
					 [pb declareTypes:[NSArray arrayWithObject:TMPasteboardTypeLink]
						 owner:self];
					 [pb setString:@"stringing" forType:TMPasteboardTypeLink];

					 NSImage *im = [NSImage imageNamed:@"common_ArrowRight.tiff"];

					 [super dragImage:im
						 at:mouseDownPoint
						 offset:NSZeroSize
						 event:anEvent
						 pasteboard:pb
						 source:self
						 slideBack:YES];

					 break;

				}

				break;
			}

			portRect.origin.y += NSHeight(portRect);
		}
	}
}

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
	NSLog(@"begin");
}


- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	NSLog(@"move %@",NSStringFromPoint(screenPoint));
}

- (unsigned) draggingUpdated: (id<NSDraggingInfo>)sender
{
	NSPoint p = [self convertPointFromBase:[sender draggingLocation]];

	NSRect portRect;
	portRect.origin = NSMakePoint(BORDER_SIZE - BORDER_LINE_SIZE, BORDER_SIZE - BORDER_LINE_SIZE*1.5);
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	//FIXME this should be cached

	while ((port = [en nextObject]))
	{
		[port setHighlight:NO];
	}

	en = [_portCells reverseObjectEnumerator];
	while ((port = [en nextObject]))
	{
		portRect.size = [port cellSize];
		portRect.size.height = MAX(NSHeight(portRect), MININUM_PORT_HEIGHT);
		portRect.size.width = MAX(NSWidth(portRect), _areaWidth) + 1.5 * BORDER_LINE_SIZE;


		if (NSPointInRect(p, portRect))
		{
			[port setHighlight:YES];
			[self setNeedsDisplay:YES];
			return NSDragOperationLink;
		}
		portRect.origin.y += NSHeight(portRect);
	}

	[self setNeedsDisplay:YES];
	return NSDragOperationNone;

}

- (unsigned int) draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal)
	{
		return NSDragOperationLink;
	}
	else
	{
		return NSDragOperationNone;
	}
}


@end

