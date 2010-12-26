#import "TMPortCell.h"

@implementation TMPortCell
- (id) initWithName:(NSString *)aName
{
	[self initTextCell:aName];
	[self setAlignment:NSCenterTextAlignment];
	return self;
}
@end

@implementation TMImportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	return self;
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();
	NSRect cf = [self drawingRectForBounds: cellFrame];


	DPSgsave(ctxt);
	{
		  DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		  DPSmoveto(ctxt, 0, 0);
		  DPSlineto(ctxt, NSWidth(cf), 0);
		  DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
		  DPSlineto(ctxt, 0, NSHeight(cf));
		  DPSarc(ctxt, 0., NSHeight(cf) - 7.5, 7.5, 90, -90);
		  DPSclosepath(ctxt);

		  DPSgsave(ctxt);
		  {
			  [[NSColor yellowColor] set];
			  DPSfill(ctxt);
		  }
		  DPSgrestore(ctxt);

		  DPSsetlinewidth(ctxt, 3);
		  [[NSColor blackColor] set];
		  DPSstroke(ctxt);

	}
	DPSgrestore(ctxt);

	[super drawInteriorWithFrame:cellFrame
		inView:controlView];

}

@end

@implementation TMExportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	return self;
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame
                        inView:(NSView *)controlView
{
	NSGraphicsContext *ctxt=GSCurrentContext();
	NSRect cf = [self drawingRectForBounds: cellFrame];


	DPSgsave(ctxt);
	{
		  DPStranslate(ctxt, NSMinX(cf), NSMinY(cf));
		  DPSmoveto(ctxt, 0, 0);
		  DPSlineto(ctxt, 0, NSHeight(cf));
		  DPSlineto(ctxt, NSWidth(cf), NSHeight(cf));
		  DPSlineto(ctxt, NSWidth(cf) + 7.5, NSHeight(cf) - 7.5);
		  DPSlineto(ctxt, NSWidth(cf), NSHeight(cf) - 15);
		  DPSlineto(ctxt, NSWidth(cf), 0);
		  DPSclosepath(ctxt);

		  DPSgsave(ctxt);
		  {
			  [[NSColor greenColor] set];
			  DPSfill(ctxt);
		  }
		  DPSgrestore(ctxt);

		  DPSsetlinewidth(ctxt, 3);
		  [[NSColor blackColor] set];
		  DPSstroke(ctxt);

	}
	DPSgrestore(ctxt);


	[super drawInteriorWithFrame:cellFrame
		inView:controlView];

}
@end


