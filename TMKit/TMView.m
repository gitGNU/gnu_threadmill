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

#import "TMDefs.h"
#import "TMView.h"
#import "TMNodeView.h"
#import "TMPortCellInternal.h"

#import <Threadmill/TMNode.h>

@interface TMView (Private)
- (void) drawWiresForNodeView:(TMNodeView *)nodeView;
@end

@class TMImportCell;
@class TMExportCell;

@implementation TMView (Private)
- (void) drawWiresForNodeView:(TMNodeView *)nodeView
{
	NSPoint a,b;

	NSEnumerator *en = [[nodeView portCells] objectEnumerator];
	TMExportCell *exportCell;
	int counter = 0;
	while ((exportCell = [en nextObject]))
	{
		if ([exportCell isKindOfClass:[TMExportCell class]])
		{
			NSRect exportFrame = [nodeView convertPortCellFrame:exportCell toView:self];

			NSGraphicsContext *ctxt=GSCurrentContext();

			NSEnumerator *en = [[exportCell pairs] objectEnumerator];
			TMImportCell *importCell;
			[[exportCell backgroundColor] set];

			while ((importCell = [en nextObject]))
			{
				counter ++;

				TMNodeView *importView = [importCell representedObject];
				NSRect importFrame = [importView convertPortCellFrame:importCell toView:self];
				/* FIXME API */
				CGFloat frameCellHight = [importView connectionHeightForExportCell:exportCell 
											toImportCell:importCell];

				importFrame.origin.y -= frameCellHight;
				/*
				frameCellHight = [importView convertPoint:NSMakePoint(0, frameCellHight) toView:self].y;
				importFrame.origin.y = frameCellHight - 1;
				importFrame.size.width = 2;
				*/


				CGFloat dist = 
					fabs(NSMaxX(exportFrame) - NSMinX(importFrame)) +
					fabs(NSMaxY(exportFrame) - NSMaxY(importFrame));

				dist /= 3;

				/* stroke wire */
				DPSmoveto(ctxt, NSMaxX(exportFrame), NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
				DPSlineto(ctxt, NSMaxX(exportFrame) + BORDER_SIZE/2, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
				DPScurveto(ctxt,
						NSMaxX(exportFrame) + BORDER_SIZE/2 + dist, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2,
					       	NSMinX(importFrame) - BORDER_SIZE/2 - dist, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2,
					       	NSMinX(importFrame) - BORDER_SIZE/2, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);
				DPSlineto(ctxt, NSMinX(importFrame), NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);

				/* draw wire outline */
				DPSgsave(ctxt); {
					[[NSColor blackColor] set];
					DPSsetlinewidth(ctxt, 2 + WIRE_WIDTH);
					DPSstroke(ctxt);
				} DPSgrestore(ctxt);

				DPSsetlinewidth(ctxt, WIRE_WIDTH);
				DPSstroke(ctxt);

#ifdef SUPERFLUOUS
				/* draw cable speculars */
				DPSgsave(ctxt); {
					DPSsetlinewidth(ctxt, WIRE_WIDTH/3);
					[[NSColor whiteColor] set];
					DPSsetalpha(ctxt, WIRE_SPECULAR_ALPHA);

					DPSmoveto(ctxt, NSMaxX(exportFrame), NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);
					DPSlineto(ctxt, NSMaxX(exportFrame) + BORDER_SIZE/2, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);
					DPScurveto(ctxt,
							NSMaxX(exportFrame) + BORDER_SIZE/2 + dist, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3,
							NSMinX(importFrame) - BORDER_SIZE/2 - dist, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3,
							NSMinX(importFrame) - BORDER_SIZE/2, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);
					DPSlineto(ctxt, NSMinX(importFrame), NSMaxY(importFrame) - MIN_PORT_HEIGHT/2 + WIRE_WIDTH/3);

					DPSstroke(ctxt);
				} DPSgrestore(ctxt);
#endif

			}

		}
	}
}

@end

@implementation TMView

NSImage *im;

+ (void) initialize
{
	im = RETAIN([NSImage imageNamed:@"FiberPattern.tiff"]);
}

- (id) init
{
	_nodes = [[NSMutableArray alloc] init];

	return [super init];
}

- (void) dealloc
{
	DESTROY(_nodes);
	[super dealloc];
}

- (TMNodeView *) addNode:(TMNode *)aNode
{
	Class viewClass = Nil;

	if (__delegate != nil)
	{
		viewClass = [__delegate viewClassForNode:aNode];
	}

	if (viewClass == Nil)
	{
		viewClass = NSClassFromString([NSStringFromClass([aNode class]) stringByAppendingString:@"View"]);
	}

	if (viewClass == Nil)
	{
		viewClass = [TMNodeView class];
	}

	TMNodeView *newNodeView = AUTORELEASE([[viewClass alloc] initWithNode:aNode]);

	[self addSubview:newNodeView];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(viewChanged:)
		name:NSViewFrameDidChangeNotification object:newNodeView];


	return newNodeView;
}

- (void) setDelegate:(id <TMNodeViewManager>)manager
{
	__delegate = manager;
}


- (void) drawRect:(NSRect)r
{
//	[[NSColor brownColor] set];
//	[[NSColor blackColor] set];
	[[NSColor colorWithDeviceRed:0.36 green:0.54 blue:0.66 alpha:1.0] set];
	NSRectFill(r);
	NSRect bounds = [self bounds];

	TMFillPatternInRect(im, r);

	NSEnumerator *en = [[self subviews] objectEnumerator];
	TMNodeView *view;

	while ((view = [en nextObject]))
	{
		[self drawWiresForNodeView:view];
	}


}


- (void) viewChanged:(NSNotification *)aNotification
{
	[self setNeedsDisplay:YES];
}

@end

