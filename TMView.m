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

#import "TMView.h"
#import "TMNodeView.h"

#import "TMNode.h"
#import "TMPort.h"

@implementation TMView (Toy)
- (void) addTestNode:(id)sender
{
	static CGFloat size = 60;

	TMNode *newNode;
	newNode = AUTORELEASE([[TMNode alloc] init]);


/* create some ports */
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test import 1"];
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"TEST \n   import 2"];
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test import 3"];

	[newNode setExport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test export 1"];
	[newNode setExport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test export 2"];

/* create node view */
	TMNodeView *newNodeView;
	newNodeView = AUTORELEASE([[TMNodeView alloc] initWithNode:newNode]);

	[self addSubview:newNodeView];
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
@end

@implementation TMView

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
	[[NSColor whiteColor] set];
	NSRectFill(r);

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
}

@end

