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
#import "TMDefs.h"



@implementation TMPortCell (Internal)

/* FIXME extern this */
NSImage *__background_pattern;

+ (void) initialize
{
	ASSIGN(__background_pattern, [NSImage imageNamed:@"FiberPattern.tiff"]);
}

- (NSComparisonResult) compareHeight:(TMPortCell *)aCell
{
	TMAxisRange r = [aCell range];
	if (_range.location < r.location) return NSOrderedAscending;
	if (_range.location > r.location) return NSOrderedDescending;
	return NSOrderedSame;

}

- (void) addConnection:(TMPortCell *)aPortCell
{
	if (_pairCells == nil)
	{
		_pairCells = [NSMutableArray new];
	}

	if (![_pairCells containsObject:aPortCell])
		[_pairCells addObject:aPortCell];
}

- (void) deleteConnection:(TMPortCell *)aPortCell
{
	[_pairCells removeObject:aPortCell];
}

/*
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	NSLog(@"end");
}
*/

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

- (TMAxisRange) range;
{
	return _range;
}

- (void) setRange:(TMAxisRange)aRange;
{
	_range = aRange;
}

@end

@implementation TMPortCell

- (id) initWithName:(NSString *)aName
{
	[self initTextCell:aName];
	[self setAlignment:NSCenterTextAlignment];
	[self setHighlightColor:[NSColor whiteColor]];

	_pairCells = [NSMutableArray new];

	return self;
}


- (void) dealloc
{
	DESTROY(_pairCells);
	DESTROY(_borderColor);
	DESTROY(_backgroundColor);
	DESTROY(_hilightColor);
	[super dealloc];
}

- (void) setBorderColor:(NSColor *)aColor
{
	ASSIGN(_borderColor, aColor);
}

- (void) setHandled:(BOOL)mode
{
	_handleMode = mode;
}

- (BOOL) isHandled
{
	return _handleMode;
}

- (NSColor *) backgroundColor
{
	return _backgroundColor;
}

- (void) setBackgroundColor:(NSColor *)aColor
{
	ASSIGN(_backgroundColor, aColor);
}

- (void) setHighlightColor:(NSColor *)aColor
{
	ASSIGN(_hilightColor, aColor);
}

- (NSArray *) pairs
{
	if (_pairCells == nil)
	{
		_pairCells = [NSMutableArray new];
	}
	return [NSArray arrayWithArray:_pairCells];
}

- (void) expandConnectors:(BOOL)shouldExpand
{
	_connectorsAreExpanded = shouldExpand;
}

- (BOOL) connectorsAreExpanded
{
	return _connectorsAreExpanded;
}

- (TMAxisRange) expandedRange
{
	return _range;
}

/*
- (void)setRepresentedObject:(id)anObject
{
	[super setRepresentedObject:anObject];

	NSView *view = anObject;
	
}
*/

#if 0
- (void) drawInteriorWithFrame:(NSRect)cellFrame
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();

	DPSgsave(ctxt); {
		NSRect cf = [self drawingRectForBounds: cellFrame];
		float dashes[6] = {1.0,2.0,4.0,5.0,6.0,7.0};
		DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		DPSsetlinewidth(ctxt, 1);
		DPSsetdash(ctxt, dashes ,2, 0.);

		if ([self isKindOfClass:[TMExportCell class]])
		{
			DPSsetrgbcolor(ctxt,0.7,0.7,0.7);
			DPSmoveto(ctxt, PORT_HANDLE_SIZE, 2);
			DPSlineto(ctxt, PORT_HANDLE_SIZE, NSHeight(cf)-2);
			DPSstroke(ctxt);
			DPSsetrgbcolor(ctxt,0.3,0.3,0.3);
			DPSmoveto(ctxt, PORT_HANDLE_SIZE, 3);
			DPSlineto(ctxt, PORT_HANDLE_SIZE, NSHeight(cf)-1);
			DPSstroke(ctxt);
		}
		else
		{
			DPSsetrgbcolor(ctxt,0.7,0.7,0.7);
			DPSmoveto(ctxt, NSWidth(cf) - PORT_HANDLE_SIZE, 2);
			DPSlineto(ctxt, NSWidth(cf) - PORT_HANDLE_SIZE, NSHeight(cf)-2);
			DPSstroke(ctxt);
			DPSsetrgbcolor(ctxt,0.3,0.3,0.3);
			DPSmoveto(ctxt, NSWidth(cf) - PORT_HANDLE_SIZE, 3);
			DPSlineto(ctxt, NSWidth(cf) - PORT_HANDLE_SIZE, NSHeight(cf)-1);
			DPSstroke(ctxt);
		}
	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame inView:controlView];
}
#endif

@end

@implementation TMImportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	[self setBackgroundColor:[NSColor orangeColor]];

	return self;
}

- (CGFloat) connectionHeightForExportCell:(TMExportCell *)exportCell
{

	/*
	if (_pairCells != nil)
	{
		NSLog(@">>%d %d", [_pairCells count], [_pairCells indexOfObject:exportCell]);
	}
	*/
	if (_connectorsAreExpanded)
		return [_pairCells indexOfObject:exportCell] * MIN_PORT_HEIGHT * 0.66;
	else return 0;
}


#ifdef DRAW_DASH_HANDLE
float dashes[6] = {0.5,5.0,4.0,5.0,6.0,7.0};
#endif
void __draw_handle_line(NSGraphicsContext *ctxt, NSRect cf, NSColor *color, CGFloat x
#ifdef SUPERFLUOUS
		,BOOL hi
#endif
		)
{
#ifdef DRAW_DASH_HANDLE
	DPSsetdash(ctxt, dashes ,2, 0.);
#endif
	/* draw handle */
	DPSsetlinewidth(ctxt, 5);
	DPSsetlinecap(ctxt, 1);
	DPSsetrgbcolor(ctxt,0,0,0);
	DPSsetalpha(ctxt,0.5);
	DPSmoveto(ctxt, x , 5);
	DPSlineto(ctxt, x , NSHeight(cf)-5);
	/*
	   DPSmoveto(ctxt, NSWidth(cf) - 11 , 9);
	   DPSlineto(ctxt, NSWidth(cf) - 11 , NSHeight(cf)-7);
	 */

	DPSgsave(ctxt); {
		DPSstroke(ctxt);
	} DPSgrestore(ctxt);

	DPSsetalpha(ctxt,1.0);
	DPSsetlinewidth(ctxt, 3);

	[color set];

#ifdef SUPERFLUOUS
	if (hi)
	{
		DPSgsave(ctxt); {
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);

		DPSgsave(ctxt); {
			DPSsetalpha(ctxt,0.2);
			DPSgsave(ctxt); {
				DPSsetlinewidth(ctxt, 7);
				DPSstroke(ctxt);
			} DPSgrestore(ctxt);
			DPSsetlinewidth(ctxt, 9);
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);
	}
	DPSstroke(ctxt);

	DPSsetalpha(ctxt,0.5);
	DPSsetlinewidth(ctxt, 1);
	DPSsetlinecap(ctxt, 1);
	DPSsetrgbcolor(ctxt,1,1,1);
	DPSsetalpha(ctxt,0.5);
	DPSmoveto(ctxt, x + 1, 5);
	DPSlineto(ctxt, x + 1 , NSHeight(cf)-5);
	DPSstroke(ctxt);
#else

	DPSstroke(ctxt);
#endif

}

- (void) drawInteriorWithFrame:(NSRect)cellFrame
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();
	NSRect cf = [self drawingRectForBounds: cellFrame];


	DPSgsave(ctxt); {
		DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		DPSmoveto(ctxt, NSWidth(cf), 0);
		DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
		DPSlineto(ctxt, 0, NSHeight(cf));

		int pCount = _pairCells != nil?[_pairCells count]:0;
		CGFloat downHigh;
		CGFloat xOnArc;
		CGFloat angleOfX;

		if (_connectorsAreExpanded && pCount > 1)
		{
			downHigh = NSHeight(cf) - MIN_PORT_HEIGHT/2 - (pCount - 1) * MIN_PORT_HEIGHT * 0.66; //FIXME define this 0.66
			DPSarc(ctxt, 0, NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/2, 90, 180);
			DPSlineto(ctxt, -MIN_PORT_HEIGHT/2, downHigh);
			if (downHigh < 0)
			{
				DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, 0);
				DPSlineto(ctxt, MIN_PORT_HEIGHT/2, 0);
			}
			else if (downHigh - MIN_PORT_HEIGHT/2 < 0)
			{
				xOnArc = sqrt(MIN_PORT_HEIGHT * MIN_PORT_HEIGHT/ 4. - (downHigh * downHigh));
				angleOfX = -atan2(downHigh, xOnArc) * 57.29577951308232;
				DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, angleOfX);
			}
			else
			{
				DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, -90);
				DPSlineto(ctxt, 0, 0);
			}

		}
		else
	       	{
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/2, 90, -90);
			DPSlineto(ctxt, 0, 0);
		}
		DPSclosepath(ctxt);

		DPSgsave(ctxt); {
			if (_cell.is_highlighted && !_handleMode)
				[_hilightColor set];
			else
				[_backgroundColor set];
			DPSfill(ctxt);
		} DPSgrestore(ctxt);
#ifdef SUPERFLUOUS
		/* fill fiber pattern */
		DPSgsave(ctxt); {
			DPSclip(ctxt);
			TMAxisRange range = [self expandedRange];
			NSRect fiberRect = NSMakeRect(- MIN_PORT_HEIGHT/2, range.location - NSMinY(cf) , NSWidth(cf) + MIN_PORT_HEIGHT/2, range.length);

			TMFillPatternInRect(__background_pattern, fiberRect);
//			[__background_pattern compositeToPoint:NSZeroPoint fromRect:fiberRect operation:NSCompositeSourceOver];

			/* draw light frame */
			[[NSColor whiteColor] set];
			DPSnewpath(ctxt);
			DPSmoveto(ctxt, NSWidth(cf), 0);
			DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
			DPSlineto(ctxt, 0, NSHeight(cf));
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/2, 90, 130);
			DPSsetalpha(ctxt,0.3);
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE + 2);
			DPSstroke(ctxt);

			[[NSColor blackColor] set];
			DPSsetalpha(ctxt,0.3);

			/* draw dark frame */
			if (_connectorsAreExpanded && pCount > 1)
			{
				DPSarc(ctxt, 0, NSHeight(cf) - MIN_PORT_HEIGHT/2,
						MIN_PORT_HEIGHT/2, 130, 180);
				DPSlineto(ctxt, -MIN_PORT_HEIGHT/2, downHigh);
				if (downHigh < 0)
				{
					DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, -50);
					DPSmoveto(ctxt, MIN_PORT_HEIGHT/2, 0);
				}
				else if (downHigh - MIN_PORT_HEIGHT/2 < 0)
				{
					DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, MIN(angleOfX, -50));
					DPSmoveto(ctxt, xOnArc, 0);
				}
				else
				{
					DPSarc(ctxt, 0, downHigh, MIN_PORT_HEIGHT/2, 180, -90);
					DPSlineto(ctxt, 0, 0);
				}

			}
			else
			{
				DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
						MIN_PORT_HEIGHT/2, 130, -90);
				DPSlineto(ctxt, 0, 0);
			}

			DPSlineto(ctxt, NSWidth(cf), 0);
			DPSstroke(ctxt);


		} DPSgrestore(ctxt);
#endif

		DPSgsave(ctxt); {
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			[_borderColor set];
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);

		int i; CGFloat yShift;

		DPSnewpath(ctxt);
		if (pCount < 2)
		{
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 0, 360);

			if (pCount == 1)
			{
				[[[_pairCells lastObject] backgroundColor] set];
			}
			else
			[[NSColor darkGrayColor] set];

			DPSclosepath(ctxt);
			DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);
			[[NSColor blackColor] set];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			DPSstroke(ctxt);
		}
		else if (_connectorsAreExpanded)
		{
			int pCount = [_pairCells count];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			for (i = 0, yShift = 0; i < pCount; i++, yShift -= MIN_PORT_HEIGHT * 0.66)
			{
				DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2 + yShift,
						MIN_PORT_HEIGHT/4, 0, 360);
				[[[_pairCells objectAtIndex:i] backgroundColor] set];
				DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);
				[[NSColor blackColor] set];
				DPSstroke(ctxt);
			}
		}
		else
	       	{
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
#ifdef SUPERFLUOUS
			/* beach ball */
			int max7 = [_pairCells count];
			if (max7 > 7) max7 = 7;

			CGFloat d = 360./max7;
			CGFloat a,b;

			int i;
			for (i = 0, a=90, b=90+d; i < max7; i++)
			{
				[[[_pairCells objectAtIndex:i] backgroundColor] set];
				DPSmoveto(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2);
				DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
						MIN_PORT_HEIGHT/4, a, b);
				DPSclosepath(ctxt);
				DPSfill(ctxt);
				a+=d;b+=d;
			}

			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 0, 360);
			DPSclosepath(ctxt);
#else
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 0, 360);
			[[NSColor darkGrayColor] set];
			DPSclosepath(ctxt);
			DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);

			[[NSColor windowBackgroundColor] set];
			DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);
#endif
			[[NSColor blackColor] set];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			DPSstroke(ctxt);

			/* draw connection counter */
			if (pCount > 1 && !_connectorsAreExpanded)
			{
				//FIXME cache these ?

				NSFont * font = [NSFont systemFontOfSize:[[self font] pointSize] * 3/4.];
				NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:font,
					NSFontAttributeName, [self textColor],
					NSForegroundColorAttributeName, nil];
				NSDictionary* hattr = [NSDictionary dictionaryWithObjectsAndKeys:font,
					NSFontAttributeName, [NSColor whiteColor],
					NSForegroundColorAttributeName, nil];

				NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", pCount] attributes:attr];
				AUTORELEASE(attrStr);

				NSRect strRect;
				strRect.size = [attrStr size];
				strRect.origin.x = MIN_PORT_HEIGHT/4 + 2*BORDER_LINE_SIZE;
				strRect.origin.y = NSHeight(cf) - MIN_PORT_HEIGHT/2 - NSHeight(strRect)/2;

#ifdef SUPERFLUOUS
				{
					NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", pCount] attributes:hattr];
					AUTORELEASE(attrStr);
					[attrStr drawInRect:NSOffsetRect(strRect, -1, -1)];
				}
#endif
				[attrStr drawInRect:strRect];



			}
		}


		/* draw beach ball speculars -- draw at last coz it sets pCount = 1 */
#ifdef SUPERFLUOUS
		if (!_connectorsAreExpanded || pCount == 0) pCount = 1;
		for (i = 0, yShift = 0; i < pCount; i++, yShift -= MIN_PORT_HEIGHT * 0.66)
		{
			DPSgsave(ctxt); {
				DPSarc(ctxt, MIN_PORT_HEIGHT/14., NSHeight(cf) - MIN_PORT_HEIGHT/2 + MIN_PORT_HEIGHT/14. + yShift,
						MIN_PORT_HEIGHT/6, 90, 450);
				[[NSColor whiteColor] set];
				DPSsetalpha(ctxt,0.3);
				DPSclosepath(ctxt);
				DPSfill(ctxt);
				DPSsetalpha(ctxt,1);
				DPSarc(ctxt, MIN_PORT_HEIGHT/12., NSHeight(cf) - MIN_PORT_HEIGHT/2 + MIN_PORT_HEIGHT/12. + yShift,
						MIN_PORT_HEIGHT/16, 90, 450);
				DPSclosepath(ctxt);
				DPSfill(ctxt);
			} DPSgrestore(ctxt);
		}
#endif

		__draw_handle_line(ctxt, cf, _handleMode?_hilightColor:_backgroundColor, NSWidth(cf) - 5
#ifdef SUPERFLUOUS
		,_handleMode
#endif
				);


	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];

}

- (TMAxisRange) expandedRange
{
	int pCount = [_pairCells count];

	if (pCount < 2) return _range;

	CGFloat expandHigh = MIN_PORT_HEIGHT + (pCount - 1) * MIN_PORT_HEIGHT * 0.66;

	return TMMakeAxisRange(_range.location + _range.length - expandHigh, expandHigh);
}


@end

@implementation TMExportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	[self setBackgroundColor:[NSColor greenColor]];
	return self;
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();
	NSRect cf = [self drawingRectForBounds: cellFrame];

	DPSgsave(ctxt); {
		DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		DPSmoveto(ctxt, 0, 0);
		DPSlineto(ctxt, 0, NSHeight(cf));
		DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
		DPSlineto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2,
				NSHeight(cf) - MIN_PORT_HEIGHT/2);
		DPSlineto(ctxt, NSWidth(cf), NSHeight(cf) - MIN_PORT_HEIGHT);
		DPSlineto(ctxt, NSWidth(cf), 0);
		DPSclosepath(ctxt);

		DPSgsave(ctxt); {
			if (_cell.is_highlighted && !_handleMode)
				[_hilightColor set];
			else
				[_backgroundColor set];
			DPSfill(ctxt);
		} DPSgrestore(ctxt);

#ifdef SUPERFLUOUS
		DPSgsave(ctxt); {
			DPSclip(ctxt);
			NSRect fiberRect;
			fiberRect.origin = NSMakePoint(10, 10);
			fiberRect.size = cellFrame.size;
			[__background_pattern compositeToPoint:NSZeroPoint fromRect:fiberRect operation:NSCompositeSourceOver];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE + 2);

			DPSnewpath(ctxt);
			DPSmoveto(ctxt, 0, NSHeight(cf));
			DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
			DPSlineto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2);
			DPSmoveto(ctxt, NSWidth(cf), NSHeight(cf) - MIN_PORT_HEIGHT);
			DPSlineto(ctxt, NSWidth(cf), 0);
			[[NSColor whiteColor] set];
			DPSsetalpha(ctxt,0.3);
			DPSstroke(ctxt);

			DPSnewpath(ctxt);
			DPSmoveto(ctxt, NSWidth(cf), 0);
			DPSlineto(ctxt, 0, 0);
			DPSlineto(ctxt, 0, NSHeight(cf));
			DPSmoveto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2);
			DPSlineto(ctxt, NSWidth(cf), NSHeight(cf) - MIN_PORT_HEIGHT);
			[[NSColor blackColor] set];
			DPSsetalpha(ctxt,0.3);
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);
#endif

		DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
		[_borderColor set];
		DPSstroke(ctxt);

		/* connect wire color to the cell color */
		if ([_pairCells count] > 0)
		{
			[_backgroundColor set];
			DPSsetlinecap(ctxt, 0);
			DPSsetlinewidth(ctxt, WIRE_WIDTH);
			DPSmoveto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2 - BORDER_LINE_SIZE * 2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2);
			DPSlineto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2 + BORDER_LINE_SIZE * 2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2);
			DPSstroke(ctxt);
#ifdef SUPERFLUOUS
			/* specular */
			[[NSColor whiteColor] set];
			DPSsetalpha(ctxt, WIRE_SPECULAR_ALPHA);
			DPSsetlinewidth(ctxt, WIRE_WIDTH/3);
			DPSmoveto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2 - BORDER_LINE_SIZE * 2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);
			DPSlineto(ctxt, NSWidth(cf) + MIN_PORT_HEIGHT/2 + BORDER_LINE_SIZE * 2,
					NSHeight(cf) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);
			DPSstroke(ctxt);
#endif
		}


		__draw_handle_line(ctxt, cf, _handleMode?_hilightColor:_backgroundColor, +5
#ifdef SUPERFLUOUS
		,_handleMode
#endif
				);

	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];
}

@end

