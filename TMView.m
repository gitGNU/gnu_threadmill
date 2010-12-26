#import "TMView.h"
#import "TMNodeView.h"

#import "TMNode.h"
#import "TMPort.h"

#import <TimeUI/TimeUI.h>

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
	[newNodeView setContentView:[[QSTimeControl alloc] initWithFrame:NSMakeRect(0, 0, size, size)]];
	size += 20;
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

