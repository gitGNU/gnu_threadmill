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


TMAxisRange TMMakeAxisRange(CGFloat location, CGFloat length)
{
	TMAxisRange range;

	range.location = location;
	range.length = length;
	return range;
}

TMAxisRange TMIntersectionAxisRange(TMAxisRange aRange, TMAxisRange bRange)
{
	
	CGFloat maxA = aRange.location + aRange.length;
	CGFloat maxB = bRange.location + bRange.length;

	if (maxA < bRange.location || maxB < aRange.location)
		return TMMakeAxisRange(0, 0);

	CGFloat maxLoc = MAX(aRange.location, bRange.location);
	return TMMakeAxisRange(maxLoc, MIN(maxA, maxB) - maxLoc);
}



@implementation TMPortCell (Internal)

/* FIXME extern this */
NSImage *__background_pattern;

+ (void) initialize
{
	ASSIGN(__background_pattern, [NSImage imageNamed:@"Carbon-Pattern.tiff"]);
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
	TMNodeView *view = [self representedObject];

	if (_pairCells == nil)
	{
		_pairCells = [NSMutableArray new];
	}

	[_pairCells addObject:aPortCell];
	[view setNeedsDisplay:YES];
}

- (void) deleteConnection:(TMPortCell *)aPortCell
{
	TMNodeView *view = [self representedObject];
	[_pairCells removeObject:aPortCell];
	[view setNeedsDisplay:YES];
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

- (void) setHighlight:(BOOL)drawHi
{
	_drawHilight = drawHi;
}

- (void) setBorderColor:(NSColor *)aColor
{
	ASSIGN(_borderColor, aColor);
}

- (void) setHandleMode:(BOOL)mode
{
	_handleMode = mode;
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
	return _pairCells;
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


#ifdef DRAW_DASH_HANDLE
float dashes[6] = {0.5,5.0,4.0,5.0,6.0,7.0};
#endif
void __draw_handle_line(NSGraphicsContext *ctxt, NSRect cf, NSColor *color, CGFloat x)
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

	DPSstroke(ctxt);

#ifdef SUPERFLUOUS
	DPSsetalpha(ctxt,0.5);
	DPSsetlinewidth(ctxt, 1);
	DPSsetlinecap(ctxt, 1);
	DPSsetrgbcolor(ctxt,1,1,1);
	DPSsetalpha(ctxt,0.5);
	DPSmoveto(ctxt, x + 1, 5);
	DPSlineto(ctxt, x + 1 , NSHeight(cf)-5);
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
		DPSmoveto(ctxt, 0, 0);
		DPSlineto(ctxt, NSWidth(cf), 0);
		DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
		DPSlineto(ctxt, 0, NSHeight(cf));
		DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
				MIN_PORT_HEIGHT/2, 90, -90);
		DPSclosepath(ctxt);

		DPSgsave(ctxt); {
			if (_drawHilight && !_handleMode)
				[_hilightColor set];
			else
				[_backgroundColor set];
			DPSfill(ctxt);
		} DPSgrestore(ctxt);
#ifdef SUPERFLUOUS
		DPSgsave(ctxt); {
			DPSclip(ctxt);
			NSRect carbonRect;
			carbonRect.origin = NSMakePoint(10, 10);
			carbonRect.size = cellFrame.size;
			[__background_pattern compositeToPoint:NSZeroPoint fromRect:carbonRect operation:NSCompositeSourceOver];
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
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/2, 130, -90);
			DPSlineto(ctxt, 0, 0);
			DPSlineto(ctxt, NSWidth(cf), 0);
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);
#endif

		DPSgsave(ctxt); {
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			[_borderColor set];
			DPSstroke(ctxt);
		} DPSgrestore(ctxt);

		DPSnewpath(ctxt);
		if (_pairCells == nil)
		{
			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 90, 450);
			[[NSColor darkGrayColor] set];
			DPSclosepath(ctxt);
			DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);
			[[NSColor blackColor] set];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			DPSstroke(ctxt);
		}
		else
	       	{
#ifdef SUPERFLUOUS
			int pCount = [_pairCells count];
			if (pCount > 7) pCount = 7;

			CGFloat d = 360./pCount;
			CGFloat a,b;

			int i;
			for (i = 0, a=90, b=90+d; i < pCount; i++)
			{
				[[[_pairCells objectAtIndex:i] backgroundColor] set];
				DPSmoveto(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2);
				DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
						MIN_PORT_HEIGHT/4, a, b);
				DPSclosepath(ctxt);
				DPSfill(ctxt);
				a+=d;b+=d;
			}
#endif


			[[[_pairCells lastObject] backgroundColor] set];

			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 0, 360);
			DPSclosepath(ctxt);
			[[NSColor blackColor] set];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			DPSstroke(ctxt);

		}

#ifdef SUPERFLUOUS
		DPSgsave(ctxt); {
			DPSarc(ctxt, MIN_PORT_HEIGHT/14., NSHeight(cf) - MIN_PORT_HEIGHT/2 + MIN_PORT_HEIGHT/14.,
					MIN_PORT_HEIGHT/6, 90, 450);
			[[NSColor whiteColor] set];
			DPSsetalpha(ctxt,0.3);
			DPSclosepath(ctxt);
			DPSfill(ctxt);
			DPSsetalpha(ctxt,1);
			DPSarc(ctxt, MIN_PORT_HEIGHT/12., NSHeight(cf) - MIN_PORT_HEIGHT/2 + MIN_PORT_HEIGHT/12.,
					MIN_PORT_HEIGHT/16, 90, 450);
			DPSclosepath(ctxt);
			DPSfill(ctxt);
		} DPSgrestore(ctxt);
#endif

		__draw_handle_line(ctxt, cf, _drawHilight?_hilightColor:_backgroundColor, NSWidth(cf) - 5);

	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];

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
			if (_drawHilight && !_handleMode)
				[_hilightColor set];
			else
				[_backgroundColor set];
			DPSfill(ctxt);
		} DPSgrestore(ctxt);

#ifdef SUPERFLUOUS
		DPSgsave(ctxt); {
			DPSclip(ctxt);
			NSRect carbonRect;
			carbonRect.origin = NSMakePoint(10, 10);
			carbonRect.size = cellFrame.size;
			[__background_pattern compositeToPoint:NSZeroPoint fromRect:carbonRect operation:NSCompositeSourceOver];
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

		__draw_handle_line(ctxt, cf, _drawHilight?_hilightColor:_backgroundColor, +5);

	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];
}

@end

