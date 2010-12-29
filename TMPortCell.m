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

#import "TMPortCell.h"
#import "TMDefs.h"

TMAxisRange TMMakeAxisRange(CGFloat location, CGFloat length)
{
	TMAxisRange range;

	range.location = location;
	range.length = length;
	return range;
}

@implementation TMPortCell
- (id) initWithName:(NSString *)aName
{
	[self initTextCell:aName];
	[self setAlignment:NSCenterTextAlignment];
	[self setHighlightColor:[NSColor whiteColor]];
	return self;
}

- (TMAxisRange) range;
{
	return _range;
}

- (void) setRange:(TMAxisRange)aRange;
{
	_range = aRange;
}

- (void) setHighlight:(BOOL)drawHi
{
	_drawHilight = drawHi;
}

- (void) setBorderColor:(NSColor *)aColor
{
	ASSIGN(_borderColor, aColor);
}

- (void) setBackgroundColor:(NSColor *)aColor
{
	ASSIGN(_backgroundColor, aColor);
}

- (void) setHighlightColor:(NSColor *)aColor
{
	ASSIGN(_hilightColor, aColor);
}
@end

@implementation TMImportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	[self setBackgroundColor:[NSColor yellowColor]];
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
			if (_drawHilight)
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
		DPSarc(ctxt, 0., NSHeight(cf) - MIN_PORT_HEIGHT/2,
				MIN_PORT_HEIGHT/4, 90, 450);
		DPSclosepath(ctxt);
		[[NSColor redColor] set];
		DPSgsave(ctxt); {DPSfill(ctxt);} DPSgrestore(ctxt);
		[[NSColor blackColor] set];
		DPSsetlinewidth(ctxt, BORDER_LINE_SIZE/2);
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
			if (_drawHilight)
				[_hilightColor set];
			else
				[_backgroundColor set];
			DPSfill(ctxt);
		} DPSgrestore(ctxt);

		DPSsetlinewidth(ctxt, BORDER_LINE_SIZE);
		[_borderColor set];
		DPSstroke(ctxt);




	} DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];
}
@end


