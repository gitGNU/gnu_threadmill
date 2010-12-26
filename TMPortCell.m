#import "TMPortCell.h"
#import "TMDefs.h"

@implementation TMPortCell
- (id) initWithName:(NSString *)aName
{
	[self initTextCell:aName];
	[self setAlignment:NSCenterTextAlignment];
	[self setHighlightColor:[NSColor whiteColor]];
	return self;
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
		  DPSarc(ctxt, 0., NSHeight(cf) - 7.5, 7.5, 90, -90);
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

		  DPSarc(ctxt, 0., NSHeight(cf) - 7.5, 3.75, 90, 450);
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
		  DPSlineto(ctxt, NSWidth(cf) + 7.5, NSHeight(cf) - 7.5);
		  DPSlineto(ctxt, NSWidth(cf), NSHeight(cf) - 15);
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


