#import "TMPort.h"

@interface TMPort (Protected)
- (void) __setConnection:(TMPort *)aPair;
@end

@implementation TMPort (Protected)
- (void) __setConnection:(TMPort *)aPair
{
	__pair = aPair;
}

@end

@implementation TMPort

- (id) initWithNode:(TMNode *)aNode
{
	__owner = aNode;
}

- (void) dealloc
{
	[self disconnect];
	[super dealloc];
}

- (void) connect:(TMPort *)aPair
{
	__pair = aPair;
	[__pair __setConnection:self];
}

- (void) disconnect
{
	[__pair __setConnection:nil];
	__pair = nil;
}

@end

