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

#import "TMNode.h" //Toy only
@interface TMView (Private)
- (void) drawWiresForNodeView:(TMNodeView *)nodeView;
@end

@class TMImportCell;
@class TMExportCell;

@implementation TMView (Toy)
- (void) addTestNode:(id)sender
{
	static CGFloat size = 60;

	TMNode *newNode;
	newNode = AUTORELEASE([[TMNode alloc] init]);


/* create some ports */
	[newNode createImportWithName:@"test import 1"];
	[newNode createImportWithName:@"TEST \n   import 2"];
	[newNode createImportWithName:@"test import 3"];

	[newNode createExportWithName:@"test export 1"];
	[newNode createExportWithName:@"test export 2"];
	[newNode createExportWithName:@"test \noh yeh\n my export 3"];

/* create node view */
	TMNodeView *newNodeView;
	newNodeView = AUTORELEASE([[TMNodeView alloc] initWithNode:newNode]);
	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.36 green:0.54 blue:0.66 alpha:1.0]
		forExport:@"test export 1"];
	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.55 green:0.71 blue:0.00 alpha:1.0]
		forExport:@"test \noh yeh\n my export 3"];

	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.82 green:0.10 blue:0.26 alpha:1.0]
		forExport:@"test export 2"];

	[self addSubview:newNodeView];
//	[_nodes addObject:newNodeView];

	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(viewChanged:)
		name:NSViewFrameDidChangeNotification object:newNodeView];

/* FIXME make node to create control view */
	NSImageView *imageView = AUTORELEASE([[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, size, size)]);
	[imageView setImage:[NSImage imageNamed:@"Threadmill-Logo.tiff"]];
	[imageView setImageScaling:NSScaleToFit];
	[newNodeView setContentView:imageView];
	size *= 2;
}

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

				DPSsetlinewidth(ctxt, 3);

				DPSmoveto(ctxt, NSMaxX(exportFrame), NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
				DPSlineto(ctxt, NSMaxX(exportFrame) + BORDER_SIZE/2, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
				DPScurveto(ctxt,
						NSMaxX(exportFrame) + BORDER_SIZE/2 + dist, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2,
					       	NSMinX(importFrame) - BORDER_SIZE/2 - dist, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2,
					       	NSMinX(importFrame) - BORDER_SIZE/2, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);
				DPSlineto(ctxt, NSMinX(importFrame), NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);

				DPSgsave(ctxt); {
					[[NSColor blackColor] set];
					DPSsetlinewidth(ctxt, 5);
					DPSstroke(ctxt);
				} DPSgrestore(ctxt);

				DPSstroke(ctxt);

#ifdef SUPERFLUOUS
				/* draw cable speculars */
				DPSgsave(ctxt); {
					[[NSColor whiteColor] set];
					DPStranslate(ctxt, 0, 1);
					DPSsetlinewidth(ctxt, 1);

					DPSmoveto(ctxt, NSMaxX(exportFrame), NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
					DPSlineto(ctxt, NSMaxX(exportFrame) + BORDER_SIZE/2, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2);
					DPScurveto(ctxt,
							NSMaxX(exportFrame) + BORDER_SIZE/2 + dist, NSMaxY(exportFrame) - MIN_PORT_HEIGHT/2,
							NSMinX(importFrame) - BORDER_SIZE/2 - dist, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2,
							NSMinX(importFrame) - BORDER_SIZE/2, NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);
					DPSlineto(ctxt, NSMinX(importFrame), NSMaxY(importFrame) - MIN_PORT_HEIGHT/2);

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

- (void) drawRect:(NSRect)r
{
//	[[NSColor brownColor] set];
	[[NSColor blackColor] set];
	NSRectFill(r);
	NSRect bounds = [self bounds];
	CGFloat i,j;
	NSRect imRect;
	imRect.origin = NSZeroPoint;
	imRect.size = [im size];
	for (j = 0; j < NSHeight(bounds); j += NSHeight(imRect))
	for (i = 0; i < NSWidth(bounds); i += NSWidth(imRect))
	{
		[im compositeToPoint:NSMakePoint(i,j) fromRect:imRect operation:NSCompositeSourceOver];
	}

	NSEnumerator *en = [[self subviews] objectEnumerator];
	TMNodeView *view;

	while ((view = [en nextObject]))
	{
		[self drawWiresForNodeView:view];
	}


}


- (void) addNode:(TMNode *)aNode
{
	/* TODO aNode should be able to specify view class */
	/*
	id nodeView = [[TMNodeView alloc] init];

	[nodeView setNode:aNode];
	[_nodes addObject:viewNode];
	[self setNeedsDisplay:YES];
	*/
	NSLog(@"NYI");
	exit(0);
}

- (void) viewChanged:(NSNotification *)aNotification
{
	[self setNeedsDisplay:YES];
}

@end

