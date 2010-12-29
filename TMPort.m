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

- (NSEnumerator *) objectEnumerator
{
	return [NSArray arrayWithObject:self];
}

- (id) initWithNode:(TMNode *)aNode
{
	[self init];

	__node = aNode;

	return self;
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

@implementation TMImport
@end

@implementation TMExport
@end
