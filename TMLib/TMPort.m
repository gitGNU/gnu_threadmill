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

#import "TMPortInternal.h"

@implementation TMPort (Internal)

+ (id) portForNode:(TMNode *)aNode
{
	TMPort *retPort = [[TMPort alloc] init];
	AUTORELEASE(retPort);

	retPort->__node = aNode;

	return retPort;
}

- (void) disconnect:(TMPort *)aPair
{
	if (![_pairs containsObject:aPair]) return;

	[_pairs removeObject:aPair];
	[aPair disconnect: self];
}

- (BOOL) connect:(TMPort *)aPair
{
	if ([_pairs containsObject:aPair]) return YES;

	[_pairs addObject:aPair];
	if (![aPair connect: self])
	{
		[_pairs removeObject:aPair];
		return NO;
	}

	return YES;
}
@end

@implementation TMPort
- (id) init
{
	_pairs = [[NSHashTable alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(_pairs);
	[super dealloc];
}

- (NSString *) description
{
	return [self name];
}

- (NSString *) name
{
	return [__node nameOfPort:self];
}

@end

