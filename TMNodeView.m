/*
	do What The Fuck you want to Public License

	Version 1.1, March 2010
	Copyright (C) 2010 Banlu Kemiyatorn.
	136 Nives 7 Jangwattana 14 Laksi Bangkok
	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.

	Ok, the purpose of this license is simple
	and you just

	DO WHAT THE FUCK YOU WANT TO.
*/

#import "TMNodeView.h"
#import "TMPortCell.h"
#import "TMNode.h"
#import "TMDefs.h"

NSDate * __distFuture;
NSString * TMPasteboardTypeImportLink = @"TMPasteboardTypeImportLink";
NSString * TMPasteboardTypeExportLink = @"TMPasteboardTypeExportLink";

void __port_set_frame(TMPortCell *port, NSRect *aFrame)
{
	TMAxisRange range = [port range];
	aFrame->origin.y = range.location;
	aFrame->size.height = range.length;
}

@interface TMNodeView (Private)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
- (TMPortCell *) _portAtPoint:(NSPoint)p;
@end

@implementation TMNodeView (Private)
- (void) _recalculateFrame
{
	BOOL contentHidden = __contentView == nil ? YES : [__contentView isHidden];

	/* calculate new title size */
	NSRect contentRect = contentHidden ? NSZeroRect : [__contentView frame];

	{
		NSSize titleSize = [_titleCell cellSize];

		_titleHeight = MAX(titleSize.height, MIN_TITLE_HEIGHT);
		_areaWidth = MAX(titleSize.width + _titleHeight + TEXT_OFFSET * 2, NSWidth(contentRect)); /* + _titleHeight for the button area */
	}

	/* expand for port name as necessary */
	CGFloat origin = BORDER_SIZE + BORDER_LINE_SIZE/2;
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		NSSize portSize = [port cellSize];
		TMAxisRange portRange = TMMakeAxisRange(origin,
			       	MAX(portSize.height, MIN_PORT_HEIGHT));
		[port setRange:portRange];
		_areaWidth = MAX(_areaWidth, portSize.width + TEXT_OFFSET * 2);

		origin += portRange.length;
	}
	_portHeight = origin - BORDER_SIZE + BORDER_LINE_SIZE/2;


	/* calculate new frame size */
	NSRect oldFrame = [self frame];
	NSRect newFrame;

	newFrame.size.height = 2 * BORDER_SIZE + _titleHeight + _portHeight;
	if (!contentHidden)
	{
		newFrame.size.height += NSHeight(contentRect) + BORDER_LINE_SIZE;
	}
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

- (TMPortCell *) _portAtPoint:(NSPoint)p
{
	NSRect portRect;
	TMPortCell *hitPort = [_portCells objectAtIndex:__hitSearchIndex];

	portRect.size.width = _areaWidth + BORDER_LINE_SIZE;
	portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE/2;
	__port_set_frame(hitPort, &portRect);

	if (NSPointInRect(p, portRect))
	{
		return hitPort;
	}

	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		if (hitPort == port) continue;

		__port_set_frame(port, &portRect);
		if (NSPointInRect(p, portRect))
		{
			__hitSearchIndex = [_portCells indexOfObject:port];
			return port;
		}
	}
	return nil;
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
	[self registerForDraggedTypes:[NSArray arrayWithObjects:TMPasteboardTypeImportLink,TMPasteboardTypeExportLink,nil]];

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

- (void) drawTitleInRect:(NSRect)r
{
	NSDictionary* blackattr;
	NSDictionary* lgrayattr;
	NSDictionary* dgrayattr;
	NSString *nodeName = [_titleCell title];
	NSFont * font = [_titleCell font];

	NSRect tf = r;
	NSSize ts = [_titleCell cellSize];
	tf.origin.x += TEXT_OFFSET;
	tf.origin.y = NSMidY(r) - ts.height/2; 
	tf.size.height = ts.height;

	if (_drawHilight)
	{
		[[NSColor whiteColor] set];
		NSFrameRect(NSOffsetRect(NSInsetRect(r,1,1),1,1));
		[[NSColor darkGrayColor] set];
		NSFrameRect(NSOffsetRect(NSInsetRect(r,1,1),-1,-1));
		[[NSColor grayColor] set];
		NSRectFill(NSInsetRect(r,1,1));


		blackattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor blackColor],
			NSForegroundColorAttributeName, nil];
		lgrayattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor lightGrayColor],
			NSForegroundColorAttributeName, nil];
		dgrayattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor darkGrayColor],
			NSForegroundColorAttributeName, nil];

	}
	else 
	{
		[[NSColor blackColor] set];
		NSFrameRect(NSOffsetRect(NSInsetRect(r,1,1),-1,-1));
		[[NSColor lightGrayColor] set];
		NSFrameRect(NSOffsetRect(NSInsetRect(r,1,1),1,1));
		[[NSColor darkGrayColor] set];
		NSRectFill(NSInsetRect(r,1,1));

		blackattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor blackColor],
			NSForegroundColorAttributeName, nil];
		lgrayattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor lightGrayColor],
			NSForegroundColorAttributeName, nil];
		dgrayattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
			NSFontAttributeName, [NSColor darkGrayColor],
			NSForegroundColorAttributeName, nil];
	}

	[nodeName drawInRect:NSOffsetRect(tf,-1,1)
		withAttributes:dgrayattr];
	[nodeName drawInRect:NSOffsetRect(tf,1,-1)
		withAttributes:lgrayattr];
	[nodeName drawInRect:tf
		withAttributes:blackattr];
}

- (void) drawRect:(NSRect)r
{
	NSRect bounds = [self bounds];

	[self drawDropShadow]; //FIXME temporary

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

	[self drawTitleInRect:textRect];
	
//	[_titleCell drawWithFrame:textRect inView:self];

	/* line under title bar */
	[_borderColor set];
	NSRectFill(NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - _titleHeight - BORDER_SIZE - BORDER_LINE_SIZE,
				_areaWidth, BORDER_LINE_SIZE
				));

	/* draw ports */
	NSRect portRect;
	portRect.size.width = _areaWidth + BORDER_LINE_SIZE;
	portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE/2;
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		__port_set_frame(port, &portRect);
		[port setBorderColor:_borderColor];
		[port drawWithFrame:portRect inView:self];
	}

	/* for debugging
	[[NSColor redColor] set];
	NSRectFill(NSInsetRect([__contentView frame],-2,-2));
	[_borderColor set];
	NSFrameRect(NSMakeRect(0,0,BORDER_SIZE, BORDER_SIZE));
	NSFrameRect(bounds);
	*/
}

- (NSView*) hitTest: (NSPoint)aPoint
{
	NSView *retView = [super hitTest:aPoint];

	if (retView == self)
	{
		/* TODO Do we need any rotation just to be supercool? */
		if (!NSPointInRect(aPoint, NSInsetRect([self frame], BORDER_SIZE, BORDER_SIZE)))
		{
			return nil;
		}

		if ([self _portAtPoint:[self convertPoint:aPoint fromView:[self superview]]] != nil)
		{
			return self;
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
		TMPortCell *port = [self _portAtPoint:mouseDownPoint];

		if (port != nil)
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

				NSPasteboard *pb;
				pb = [NSPasteboard pasteboardWithName:NSDragPboard];

				id type;


				if ([port isKindOfClass:[TMImportCell class]])
				{
					type = TMPasteboardTypeImportLink;
				}
				else
				{
					type = TMPasteboardTypeExportLink;
				}

				[pb declareTypes:[NSArray arrayWithObject:type] owner:self];
				[pb setString:[port title] forType:type];

				[port setHighlight:YES];
				__portDragOut = port;
				[super dragImage:[NSImage imageNamed:@"Plug.tiff"]
					at:mouseDownPoint
					offset:NSZeroSize
					event:anEvent
					pasteboard:pb
					source:self
					slideBack:YES];

				break;

			}
		}
	}
}

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
	NSLog(@"begin");
}

- (void) setNeedsDisplayPortCells
{
//	[self setNeedsDisplayInRect: NYI
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[__portInLight setHighlight:NO];
	__portInLight = nil;
	[self setNeedsDisplay:YES]; //FIXME only need to update the port frame
	NSLog(@"exit");
}

- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	NSLog(@"move %@",NSStringFromPoint(screenPoint));
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	[__portDragOut setHighlight:NO];
	__portDragOut = nil;
	[self setNeedsDisplay:YES]; //FIXME only need to update the port frame
}

- (unsigned) draggingUpdated: (id<NSDraggingInfo>)sender
{

	NSPasteboard *pb = [sender draggingPasteboard];
	NSArray *types = [pb types];

	TMPortCell *port = [self _portAtPoint:[self convertPointFromBase:[sender draggingLocation]]];

	if (__portInLight != port)
	{
		[__portInLight setHighlight:NO];
		__portInLight = nil;
		[self setNeedsDisplay:YES];
	}

	if (port != nil)
	{
		if ([port isKindOfClass:[TMImportCell class]])
		{
			if ([types containsObject:TMPasteboardTypeExportLink])
			{
				[port setHighlight:YES];
				__portInLight = port;
				[self setNeedsDisplay:YES];
				return NSDragOperationLink;
			}
		}
		else //TMExportCell
		{
			if ([types containsObject:TMPasteboardTypeImportLink])
			{
				[port setHighlight:YES];
				__portInLight = port;
				[self setNeedsDisplay:YES];
				return NSDragOperationLink;
			}
		}

	}

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

- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{

	NSPasteboard *pb = [sender draggingPasteboard];
	NSDragOperation opMask = [sender draggingSourceOperationMask];
	NSArray *types = [pb types];


	if ([types containsObject:TMPasteboardTypeImportLink])
	{

		NSLog(@"%@ -> %@", [__portInLight title], [pb stringForType:TMPasteboardTypeImportLink]);
	}
	else if ([types containsObject:TMPasteboardTypeExportLink])
	{
		NSLog(@"%@ <- %@", [__portInLight title], [pb stringForType:TMPasteboardTypeExportLink]);
	}

	[__portInLight setHighlight:NO];
	__portInLight = nil;
	[self setNeedsDisplay:YES];

	return YES;

}

@end

