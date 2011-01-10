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
#import "TMPortCellInternal.h"
#import "TMNode.h"
#import "TMDefs.h"

NSDate * __distFuture;

void __port_set_frame(TMPortCell *port, NSRect *aFrame)
{
	TMAxisRange range = [port range];
	aFrame->origin.y = range.location;
	aFrame->size.height = range.length;
}

@interface TMTitleButtonCell : NSButtonCell
{
	BOOL mode;
}
- (void) toggle;
@end

@implementation TMTitleButtonCell
- (void) toggle
{
	mode = !mode;
}

- (void) drawInteriorWithFrame:(NSRect)cf
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();
//	NSRect cf = [self drawingRectForBounds: cf];

	/* just draw arrow */
	DPSgsave(ctxt); {
		DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));

		DPSsetlinejoin(ctxt, 1);
		DPSsetlinecap(ctxt, 1);

		if ([self isHighlighted])
		{
			//FIXME define highlight color
			//DPSsetrgbcolor(ctxt,0.5,0.7,1.0);
			[[NSColor whiteColor] set];
		}
		else
			[[NSColor grayColor] set];

		DPSmoveto(ctxt, NSWidth(cf)/2 + NSWidth(cf)/4., NSHeight(cf) * (mode?2:1)/3.);
		DPSlineto(ctxt, NSWidth(cf)/2, NSHeight(cf) * (mode?1:2)/3.);
		DPSlineto(ctxt, NSWidth(cf)/2 - NSWidth(cf)/4., NSHeight(cf) * (mode?2:1)/3.);
	//	DPSclosepath(ctxt);
#ifdef SUPERFLUOUS
		if ([self isHighlighted])
		{
			DPSgsave(ctxt); {
					DPSgsave(ctxt); {
						DPSsetalpha(ctxt,0.1);
						DPSsetlinewidth(ctxt, MIN_PORT_HEIGHT/2.5);
						DPSstroke(ctxt);
					} DPSgrestore(ctxt);
				DPSsetalpha(ctxt,0.3);
				DPSsetlinewidth(ctxt, MIN_PORT_HEIGHT/5.);
				DPSstroke(ctxt);
			} DPSgrestore(ctxt);
		}
#endif
		DPSsetlinewidth(ctxt, MIN_PORT_HEIGHT/10);
		DPSstroke(ctxt);
	} DPSgrestore(ctxt);
}
@end

@interface TMNodeView (Internal)
- (void) _recalculateFrame;
- (void) _setNode:(TMNode *)aNode;
- (void) _handlePort:(TMPortCell *)aPort sortingFromPoint:(NSPoint)mouseDownPoint;
@end

@implementation TMNodeView (Internal)
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

	NSEnumerator *en = [_portCells objectEnumerator];
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
	/*
	if (__contentView != nil && contentHidden)
	{
		[_contentButtonCell setImage:[NSImage imageNamed:@"common_ArrowDown.tiff"]];
	}
	else
	{
		[_contentButtonCell setImage:[NSImage imageNamed:@"common_ArrowUp.tiff"]];
	}
	*/

	if (!contentHidden)
	{
		contentRect.origin.x = BORDER_SIZE + (_areaWidth / 2) - (NSWidth(contentRect) / 2);
		contentRect.origin.y = NSMaxY(bounds) - _titleHeight
			- BORDER_SIZE - NSHeight(contentRect) - BORDER_LINE_SIZE;
		[__contentView setFrameOrigin:contentRect.origin];
	}

	[self setNeedsDisplay:YES];
}

- (void) _setNode:(TMNode*)aNode
{
	ASSIGN(_node, aNode);
	[_titleCell setTitle:[_node name]];

	NSDictionary* whiteAttr;
	whiteAttr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:[[_titleCell font] pointSize]],
		  NSFontAttributeName, [NSColor whiteColor],
		  NSForegroundColorAttributeName, nil];
	NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[_node name] attributes:whiteAttr];

	[_titleCell setAttributedTitle:attrStr];
	AUTORELEASE(attrStr);
	[self _recalculateFrame];

	[self setNeedsDisplay:YES];
}

- (void) _handlePort:(TMPortCell *)aPort sortingFromPoint:(NSPoint)mouseDownPoint;
{
	NSEvent *anEvent;

	[aPort setHandled:YES];
	[self setNeedsDisplay:YES];
	TMAxisRange r = [aPort range];
	CGFloat draggedLocation = r.location;

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

		NSPoint p = [self convertPointFromBase:[anEvent locationInWindow]];
		p.y = p.y - mouseDownPoint.y;

		TMAxisRange dragRange = TMMakeAxisRange(r.location + p.y,r.length);
		CGFloat origin = BORDER_SIZE + BORDER_LINE_SIZE/2;
		if (dragRange.location < origin)
		{
			dragRange.location = origin;
		}
		else if (dragRange.location > origin - BORDER_LINE_SIZE + _portHeight - dragRange.length) 
		{
			dragRange.location = origin - BORDER_LINE_SIZE + _portHeight - dragRange.length;
		}
		draggedLocation = dragRange.location;

		[aPort setRange:dragRange];

		NSEnumerator *en;
		TMPortCell *portCell;
		[_portCells sortUsingSelector:@selector(compareHeight:)];
		en = [_portCells objectEnumerator];
		while ((portCell = [en nextObject]))
		{
			CGFloat diffLo,diffHi;

			if (portCell == aPort)
			{
				continue;
			}

			TMAxisRange portRange = [portCell range];
			portRange.location = origin;

			diffLo = TMIntersectionAxisRange(portRange, dragRange).length;

			if (diffLo > 0.)
			{
				diffHi = TMIntersectionAxisRange(TMMakeAxisRange(portRange.location + dragRange.length, portRange.length), dragRange).length;
				if (diffHi < diffLo)
				{
					draggedLocation = origin;
					portRange.location += dragRange.length;
					[portCell setRange:portRange];
					origin += dragRange.length + portRange.length;
				}
				else
				{
					draggedLocation = origin + portRange.length;
					[portCell setRange:portRange];
					origin += dragRange.length + portRange.length;
				}
			}
			else
			{
				[portCell setRange:portRange];
				origin += portRange.length;
			}

		}

		//FIXME optimize display
		[[self superview] setNeedsDisplay:YES];

	}
	[aPort setHandled:NO];
	r.location = draggedLocation;
	[aPort setRange:r];
	//FIXME optimize display
	[[self superview] setNeedsDisplay:YES];
}


@end

@implementation TMNodeView

+ (void) initialize
{
	__distFuture = [NSDate distantFuture];
}

- (id) initWithNode:(TMNode *)aNode
{
	ASSIGN(_titleCell, [[NSButtonCell alloc] initTextCell:@"Node"]);
	ASSIGN(_borderColor, [NSColor blackColor]);
	[_titleCell setBezelStyle:NSDisclosureBezelStyle];

	[self initWithFrame:NSMakeRect(0, 0, 200, 300)]; //FIXME

	_contentButtonCell = [TMTitleButtonCell new];
	[_contentButtonCell setTarget:self];
	[_contentButtonCell setAction:@selector(toggleContent:)];
	[_contentButtonCell setBezelStyle:NSDisclosureBezelStyle];

	[self _setNode:aNode];

	_portCells = [[NSMutableArray alloc] init];

	/* imports */

	NSEnumerator *en;
	NSString *aName;
/*
	NSArray * sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]];
*/

	id cell;
	en = [[[_node importList] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectEnumerator];
	while ((aName = [en nextObject]))
	{
		cell = AUTORELEASE([[TMImportCell alloc] initWithPortName:aName]);
		[cell setRepresentedObject:self];
		[_portCells addObject:cell];
	}

	/* exports */

	en = [[[_node exportList] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectEnumerator];
	while ((aName = [en nextObject]))
	{
		cell = AUTORELEASE([[TMExportCell alloc] initWithPortName:aName]);
		[cell setRepresentedObject:self];
		[_portCells addObject:cell];
	}

	[self registerForDraggedTypes:[NSArray arrayWithObjects:TMPasteboardTypeImportLink, TMPasteboardTypeExportLink, nil]];

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

		DPSsetrgbcolor(ctxt,0.3,0.8,1.0);
#ifdef SUPERFLUOUS
		DPSsetalpha(ctxt, 0.1);
		DPSsetlinewidth(ctxt, 16);
#else
		DPSsetlinewidth(ctxt, 13);
#endif
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));

#ifdef SUPERFLUOUS
		DPSsetalpha(ctxt, 0.3);
		DPSsetlinewidth(ctxt, 10);
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));

		DPSsetlinewidth(ctxt, 8);
		DPSrectstroke(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));
#endif
	}
}

- (void) drawTitleInRect:(NSRect)r
{
	[[NSColor blackColor] set];
	NSRectFill(r);
#ifdef SUPERFLUOUS
	NSRect fiberRect;
	fiberRect.origin = NSMakePoint(10,10);
	fiberRect.size = r.size;
	TMFillPatternInRect([NSImage imageNamed:@"FiberPattern.tiff"], r);

	/* frame */
	NSGraphicsContext *ctxt=GSCurrentContext();
	DPSgsave(ctxt); {
		DPSsetlinewidth(ctxt, 2);
		DPSrectclip(ctxt, NSMinX(r), NSMinY(r), NSWidth(r), NSHeight(r));
		DPSmoveto(ctxt, NSMinX(r), NSMaxY(r));
		DPSlineto(ctxt, NSMaxX(r), NSMaxY(r));
		DPSlineto(ctxt, NSMaxX(r), NSMinY(r));
		[[NSColor lightGrayColor] set];
		DPSsetalpha(ctxt,0.3);
		DPSstroke(ctxt);
		DPSmoveto(ctxt, NSMinX(r), NSMaxY(r));
		DPSlineto(ctxt, NSMinX(r), NSMinY(r));
		DPSlineto(ctxt, NSMaxX(r), NSMinY(r));
		[[NSColor blackColor] set];
		DPSsetalpha(ctxt,0.3);
		DPSstroke(ctxt);
	} DPSgrestore(ctxt);
#endif
	/*
	[[NSColor darkGrayColor] set];
	NSRectFill(NSInsetRect(r, 1, 1));
	*/

	NSRect textTitleRect;
	textTitleRect.origin.x = NSMinX(r) + _titleHeight;
	textTitleRect.origin.y = NSMinY(r);
	textTitleRect.size.width = NSWidth(r) - _titleHeight;
	textTitleRect.size.height = NSHeight(r);
	[_titleCell drawWithFrame:textTitleRect inView:self];
#if 0
	NSDictionary* blackattr;
	NSDictionary* lgrayattr;
	NSDictionary* dgrayattr;
	NSString *nodeName = [_titleCell title];
	NSFont * font = [_titleCell font];

	NSRect tf = r;
	NSSize ts = [_titleCell cellSize];
	tf.origin.x += TEXT_OFFSET + _titleHeight;
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
#endif

	r.size.width = r.size.height;
	
	[_contentButtonCell drawWithFrame:r inView:self];
}

- (void) drawRect:(NSRect)r
{
	NSRect bounds = [self bounds];

	[self drawDropShadow]; //FIXME temporary

	/* fill body */
	[_borderColor set];

	NSRectFill(NSMakeRect(BORDER_SIZE - BORDER_LINE_SIZE, 
				BORDER_SIZE,
				NSWidth(bounds) - BORDER_SIZE * 2 + BORDER_LINE_SIZE * 2,
				NSHeight(bounds) - 2 * BORDER_SIZE + BORDER_LINE_SIZE));


	if (__contentView != nil && ![__contentView isHidden])
	{
		[[NSColor windowBackgroundColor] set];
		NSRectFill(NSMakeRect(BORDER_SIZE, 
					BORDER_SIZE + _portHeight,
					NSWidth(bounds) - BORDER_SIZE * 2,
					NSHeight([__contentView frame])));
	}

	/* draw title */
	[self drawTitleInRect:NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - _titleHeight - BORDER_SIZE,_areaWidth, _titleHeight)];
	

	/* line under title bar */
	[_borderColor set];
	NSRectFill(NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - _titleHeight - BORDER_SIZE - BORDER_LINE_SIZE,
				_areaWidth, BORDER_LINE_SIZE));

	[[NSColor darkGrayColor] set];
	NSRectFill(NSMakeRect(BORDER_SIZE, BORDER_SIZE + BORDER_LINE_SIZE,
			       	_areaWidth, _portHeight - BORDER_LINE_SIZE * 2));
#ifdef SUPERFLUOUS
	[[NSImage imageNamed:@"FiberPattern.tiff"]
	       	drawAtPoint:NSMakePoint(BORDER_SIZE, BORDER_SIZE + BORDER_LINE_SIZE)
		fromRect:NSMakeRect(0,0,_areaWidth, _portHeight - BORDER_LINE_SIZE * 2)
	       	operation:NSCompositeSourceOver
		fraction:1];
#endif

	/* draw ports */
	NSRect portRect;
	portRect.size.width = _areaWidth + BORDER_LINE_SIZE;
	portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE/2;

	NSEnumerator *en = [_portCells objectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		if ([port isHandled] || [port connectorsAreExpanded]) continue;
		__port_set_frame(port, &portRect);
		[port setBorderColor:_borderColor];
		[port drawWithFrame:portRect inView:self];
	}

	en = [_portCells objectEnumerator];
	while ((port = [en nextObject]))
	{
		if ([port isHandled])
		{
			__port_set_frame(port, &portRect);
			[port setBorderColor:_borderColor];
			[port drawWithFrame:NSInsetRect(portRect, -2, 0) inView:self];
		}
		else if ([port connectorsAreExpanded])
		{
			__port_set_frame(port, &portRect);
			[port setBorderColor:_borderColor];
			[port drawWithFrame:portRect inView:self];
		}
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

		if ([self portCellAtPoint:[self convertPoint:aPoint fromView:[self superview]]] != nil)
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
	[_contentButtonCell toggle];

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
	TMPortCell *mouseDownPort;

	/* display mouse down here */

	NSColor *oldBorderColor = nil;
	ASSIGN(oldBorderColor, _borderColor);
	AUTORELEASE(oldBorderColor);


	/* FIXME track cells somewhere else */

	/* mouse down in content switch */
	NSRect buttonRect = NSMakeRect(BORDER_SIZE, NSMaxY(bounds) - _titleHeight - BORDER_SIZE,_titleHeight, _titleHeight);
	if (NSPointInRect(mouseDownPoint, buttonRect))
	{
		while (YES)
		{
			//FIXME set hilight
			[_contentButtonCell setHighlighted:YES];
			[self setNeedsDisplay:YES];
			BOOL cond = [_contentButtonCell trackMouse:anEvent
				inRect:buttonRect
				ofView:self    
				untilMouseUp:NO];
			[_contentButtonCell setHighlighted:NO];
			[self setNeedsDisplay:YES];

			if (cond == YES) break;

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
		}
	}
	/* mouse down in title - track frame movement */
	else if (NSPointInRect(mouseDownPoint, NSMakeRect(0,
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
	else if ((mouseDownPort = [self portCellAtPoint:mouseDownPoint]) != nil)
	{
		NSRect portRect;
		portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE;
		portRect.origin.y = BORDER_SIZE - BORDER_LINE_SIZE*1.5;

		NSEnumerator *en = [_portCells reverseObjectEnumerator];

		/* mouse down on handle - track sorting handle */
		if ((mouseDownPoint.x - BORDER_SIZE < PORT_HANDLE_SIZE && [mouseDownPort isKindOfClass:[TMExportCell class]])
				|| (mouseDownPoint.x - BORDER_SIZE - _areaWidth > -PORT_HANDLE_SIZE && [mouseDownPort isKindOfClass:[TMImportCell class]]))
		{
			[self _handlePort:mouseDownPort sortingFromPoint:mouseDownPoint];
		}
		/* mouse down on import connector */
		else if ((mouseDownPoint.x - BORDER_SIZE < PORT_HANDLE_SIZE && [mouseDownPort isKindOfClass:[TMImportCell class]]))
		{
			NSPoint mouseLoc = mouseDownPoint;
			[mouseDownPort expandConnectors:YES];
			[[self superview] setNeedsDisplay:YES];

			TMAxisRange range = [mouseDownPort expandedRange];
			NSRect trackArea = NSMakeRect(BORDER_SIZE - MIN_PORT_HEIGHT/2, range.location, PORT_HANDLE_SIZE + MIN_PORT_HEIGHT/2, range.length);
			/* extend area for ease of pointing TODO use alarmer instead */
			trackArea = NSInsetRect(trackArea, -20, -20);
			trackArea = NSIntegralRect(trackArea);

			while (YES)
			{
				anEvent = [NSApp nextEventMatchingMask:
					NSLeftMouseDownMask |
					NSLeftMouseUpMask |
					NSLeftMouseDraggedMask |
					NSMouseMovedMask
					untilDate:__distFuture
					inMode:NSEventTrackingRunLoopMode
					dequeue:YES];

				NSEventType eventType = [anEvent type];

				if (eventType == NSMouseMoved)
				{
					mouseLoc = [self convertPointFromBase:[anEvent locationInWindow]];

					if (!NSPointInRect(mouseLoc, trackArea))
					{
						break;
					}
				}
				else if (eventType == NSLeftMouseDown)
				{
				}
				else if (eventType == NSLeftMouseUp)
				{
					mouseLoc = [self convertPointFromBase:[anEvent locationInWindow]];
					if (!NSPointInRect(mouseLoc, trackArea))
					{
						break;
					}
				}
				else if (eventType == NSLeftMouseDragged)
				{
					mouseLoc = [self convertPointFromBase:[anEvent locationInWindow]];
					if (!NSPointInRect(mouseLoc, trackArea))
					{
						//FIXME just break all connections for now, turn it into DnD for other port later.
						NSEnumerator *en = [[mouseDownPort pairs] objectEnumerator];
						TMPortCell *remotePort;
						while ((remotePort = [en nextObject]))
						{
							[remotePort deleteConnection:mouseDownPort];
							[mouseDownPort deleteConnection:remotePort];
						}


						[[self superview] setNeedsDisplay:YES]; //FIXME optimize display

						NSLog(@"break in dragged");
						break;
					}
				}

			}

			[mouseDownPort expandConnectors:NO];
			[[self superview] setNeedsDisplay:YES];
		}
		/* mouse down on port content - track DnD linking */
		else 
		{
			BOOL pairOn = YES;
			[mouseDownPort setHighlighted:YES];
			[self setNeedsDisplay:YES];
			NSEnumerator *en = [[mouseDownPort pairs] objectEnumerator];
			TMPortCell *pairPort;
			while ((pairPort = [en nextObject]))
			{
				[pairPort setHighlighted:YES];
			}
			[[self superview] setNeedsDisplay:YES]; // FIXME optimize this

			while (YES)
			{
				anEvent = [NSApp nextEventMatchingMask:
					NSLeftMouseUpMask |
					NSLeftMouseDraggedMask |
					NSMouseMovedMask
					untilDate:__distFuture
					inMode:NSEventTrackingRunLoopMode
					dequeue:YES];

				if (pairOn)
				{
					pairOn = NO;
					en = [[mouseDownPort pairs] objectEnumerator];
					while ((pairPort = [en nextObject]))
					{
						[pairPort setHighlighted:NO];
					}
					[[self superview] setNeedsDisplay:YES]; // FIXME optimize this
				}

				NSEventType eventType = [anEvent type];

				if (eventType == NSLeftMouseUp)
				{
					/* handle expanded connector */

					break;
				}

				NSPasteboard *pb;
				pb = [NSPasteboard pasteboardWithName:NSDragPboard];

				id type;


				if ([mouseDownPort isKindOfClass:[TMImportCell class]])
				{
					type = TMPasteboardTypeImportLink;
				}
				else
				{
					type = TMPasteboardTypeExportLink;
				}

				[pb declareTypes:[NSArray arrayWithObject:type] owner:self];
				[pb setString:[mouseDownPort title] forType:type];

				[super dragImage:[NSImage imageNamed:@"Plug.tiff"]
					at:mouseDownPoint
					offset:NSZeroSize
					event:anEvent
					pasteboard:pb
					source:mouseDownPort
					slideBack:YES];

				break;

			}
			[mouseDownPort setHighlighted:NO];
			[self setNeedsDisplay:YES];
		}
	}
}

/* FIXME source changed to cell
- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint
{
	NSLog(@"begin");
}

- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint
{
	NSLog(@"move %@",NSStringFromPoint(screenPoint));
}

*/

- (void) setNeedsDisplayPortCells
{
//	[self setNeedsDisplayInRect: NYI
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
	[__portInLight setHighlighted:NO];
	__portInLight = nil;
	[self setNeedsDisplay:YES]; //FIXME only need to update the port frame
}

- (unsigned) draggingUpdated: (id<NSDraggingInfo>)sender
{

	NSPasteboard *pb = [sender draggingPasteboard];
	NSArray *types = [pb types];

	TMPortCell *sourcePort = [sender draggingSource];
	TMPortCell *targetPort = [self portCellAtPoint:[self convertPointFromBase:[sender draggingLocation]]];


	if (__portInLight != targetPort)
	{
		[__portInLight setHighlighted:NO];
		__portInLight = nil;
		[self setNeedsDisplay:YES];
	}

	if (targetPort != nil && ![[targetPort pairs] containsObject:sourcePort])
	{
		if ([targetPort isKindOfClass:[TMImportCell class]])
		{
			if ([types containsObject:TMPasteboardTypeExportLink])
			{
				[targetPort setHighlighted:YES];
				__portInLight = targetPort;
				[self setNeedsDisplay:YES];
				return NSDragOperationLink;
			}
		}
		else //TMExportCell
		{
			if ([types containsObject:TMPasteboardTypeImportLink])
			{
				[targetPort setHighlighted:YES];
				__portInLight = targetPort;
				[self setNeedsDisplay:YES];
				return NSDragOperationLink;
			}
		}

	}

	return NSDragOperationNone;
}

- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender
{

	NSPasteboard *pb = [sender draggingPasteboard];
	NSDragOperation opMask = [sender draggingSourceOperationMask];
	NSArray *types = [pb types];

	TMPortCell *sourcePort = [sender draggingSource];
	TMPortCell *targetPort = __portInLight;

	TMNodeView *sourceView = [sourcePort representedObject];


	if ([types containsObject:TMPasteboardTypeImportLink])
	{
		[_node setExport:[targetPort portName]
			forImport:[pb stringForType:TMPasteboardTypeImportLink]
			onNode:sourceView->_node];
	}
	else if ([types containsObject:TMPasteboardTypeExportLink])
	{
		[sourceView->_node setExport:[pb stringForType:TMPasteboardTypeImportLink]
			forImport:[targetPort portName]
			onNode:_node];
	}

	[sourcePort addConnection:targetPort];
	[targetPort addConnection:sourcePort];

	[__portInLight setHighlighted:NO];
	__portInLight = nil;

	//FIXME optimize display
	[[self superview] setNeedsDisplay:YES];

	return YES;

}

- (NSSet *) importNames
{
	return [_node importNames];
}

- (NSSet *) exportNames
{
	return [_node exportNames];
}

/*
- (NSRect) frameForPortCellOfClass:(Class)class
	withName:(NSString *)aName
{
	NSEnumerator *en;
	en = [_portCells objectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		if ([port isKindOfClass:class])
		{
			if ([[port title] isEqualToString:aName])
			{
				NSRect portRect;
				portRect.size.width = _areaWidth + BORDER_LINE_SIZE;
				portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE/2;
				__port_set_frame(port, &portRect);

				return portRect;
			}
		}
	}

	return NSZeroRect;

}
*/

- (NSArray *) portCells
{
	return _portCells;
}

- (NSRect) convertPortCellFrame:(TMPortCell *)aCell
			toView:(NSView *)aView
{
	NSRect portRect;
	portRect.size.width = _areaWidth + BORDER_LINE_SIZE;
	portRect.origin.x = BORDER_SIZE - BORDER_LINE_SIZE/2;
	__port_set_frame(aCell, &portRect);
	return [self convertRect:portRect toView:aView];
}

/* fix me */
- (CGFloat) connectionHeightForExportCell:(TMExportCell *)exportCell
			toImportCell:(TMImportCell *)importCell
{
//	NSLog(@"check %d", [_portCells indexOfObject:importCell]);

	return [importCell connectionHeightForExportCell:exportCell];
}


- (TMPortCell *) portCellAtPoint:(NSPoint)p
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

- (void) setBackgroundColor:(NSColor *)aColor
	forImport:(NSString *)importName
{
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		if ([port isKindOfClass:[TMImportCell class]] && 
				[[port portName] isEqualToString:importName])
		{
			[port setBackgroundColor:aColor];
			[self setNeedsDisplay:YES];
			return;
		}
	}
}

- (void) setBackgroundColor:(NSColor *)aColor
	forExport:(NSString *)exportName
{
	NSEnumerator *en = [_portCells reverseObjectEnumerator];
	TMPortCell *port;
	while ((port = [en nextObject]))
	{
		if ([port isKindOfClass:[TMExportCell class]] && 
				[[port portName] isEqualToString:exportName])
		{
			[port setBackgroundColor:aColor];
			[self setNeedsDisplay:YES];
			return;
		}
	}
}


@end

