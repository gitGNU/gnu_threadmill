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
	NSRect cf = [self drawingRectForBounds: cellFrame];
	/* handle */
	DPSgsave(ctxt); {
		DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		DPSsetlinewidth(ctxt, 1);
		DPSsetrgbcolor(ctxt,0,0,0);
		DPSmoveto(ctxt, NSWidth(cf) - 3 , 3);
		DPSlineto(ctxt, NSWidth(cf) - 6 , 3);
		DPSlineto(ctxt, NSWidth(cf) - 3 , 6);
		DPSclosepath(ctxt);
		DPSstroke(ctxt);
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


			[[[_pairCells lastObject] backgroundColor] set];

			DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
					MIN_PORT_HEIGHT/4, 0, 360);
			DPSclosepath(ctxt);
			[[NSColor blackColor] set];
			DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
			DPSstroke(ctxt);

		}


		/* draw handle */
		DPSsetlinewidth(ctxt, 5);
		DPSsetlinecap(ctxt, 1);
		DPSsetrgbcolor(ctxt,0,0,0);
		DPSsetalpha(ctxt,0.5);
		DPSmoveto(ctxt, NSWidth(cf) - 5 , 5);
		DPSlineto(ctxt, NSWidth(cf) - 5 , NSHeight(cf)-5);
		DPSstroke(ctxt);

		DPSsetalpha(ctxt,1.0);
		DPSsetlinewidth(ctxt, 3);
		DPSmoveto(ctxt, NSWidth(cf) - 5 , 5);
		DPSlineto(ctxt, NSWidth(cf) - 5 , NSHeight(cf)-5);
		if (_drawHilight)
			[_hilightColor set];
		else
			[_backgroundColor set];
		DPSstroke(ctxt);

		DPSsetalpha(ctxt,0.5);
		DPSsetlinewidth(ctxt, 1);
		DPSsetlinecap(ctxt, 1);
		DPSsetrgbcolor(ctxt,1,1,1);
		DPSsetalpha(ctxt,0.5);
		DPSmoveto(ctxt, NSWidth(cf) - 4 , 5);
		DPSlineto(ctxt, NSWidth(cf) - 4 , NSHeight(cf)-5);
		DPSstroke(ctxt);

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

		DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
		[_borderColor set];
		DPSstroke(ctxt);

		/* draw handle */
		DPSsetlinewidth(ctxt, 5);
		DPSsetlinecap(ctxt, 1);
		DPSsetrgbcolor(ctxt,0,0,0);
		DPSsetalpha(ctxt,0.5);
		DPSmoveto(ctxt, 5 , 5);
		DPSlineto(ctxt, 5 , NSHeight(cf)-5);
		DPSstroke(ctxt);

		DPSsetalpha(ctxt,1.0);
		DPSsetlinewidth(ctxt, 3);
		DPSmoveto(ctxt, 5 , 5);
		DPSlineto(ctxt, 5 , NSHeight(cf)-5);
		if (_drawHilight)
			[_hilightColor set];
		else
			[_backgroundColor set];
		DPSstroke(ctxt);

		DPSsetalpha(ctxt,0.5);
		DPSsetlinewidth(ctxt, 1);
		DPSsetlinecap(ctxt, 1);
		DPSsetrgbcolor(ctxt,1,1,1);
		DPSsetalpha(ctxt,0.5);
		DPSmoveto(ctxt, 6 , 5);
		DPSlineto(ctxt, 6 , NSHeight(cf)-5);
		DPSstroke(ctxt);
	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];
}

@end

