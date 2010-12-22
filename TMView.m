#import "TMView.h"
#import "TMNodeView.h"

#import "TMNode.h"
#import "TMPort.h"

@implementation TMView (Toy)
- (void) addTestNode:(id)sender
{

	TMNode *newNode;
	newNode = AUTORELEASE([[TMNode alloc] init]);


/* create some ports */
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test import 1"];
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test import 2"];
	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test import 3"];

	[newNode setImport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test export 1"];
	[newNode setExport:AUTORELEASE([[TMPort alloc] initWithNode:newNode])
		   forName:@"test export 2"];

/* create node view */
	TMNodeView *newNodeView;
	newNodeView = AUTORELEASE([[TMNodeView alloc] initWithNode:newNode]);

	[self addSubview:newNodeView];

	
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

@end

