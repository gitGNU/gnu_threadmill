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
	int i = 0, j = 0;
	while (i < _pairCount)
	{
		if (_pairs[i] != aPair)
		{
			_pairs[j] = _pairs[i];
			j++;
		}
		i++;
	}

	if (j < _pairCount)
	{
		_pairCount = j;
		[aPair disconnect: self];
	}

}

- (BOOL) connect:(TMPort *)aPair
{
	int i = 0;
	while (i < _pairCount)
	{
		if (_pairs[i] == aPair)
		       	return YES;
		i++;
	}

	_pairCount++;
	_pairs = realloc(_pairs, sizeof(id) * _pairCount);
	_pairs[_pairCount - 1] = aPair;

	if (![aPair connect: self])
	{
		_pairCount--;
		_pairs = realloc(_pairs, sizeof(id) * _pairCount);
		return NO;
	}

	return YES;
}

- (BOOL) prepareWithPriority: (NSInteger)priority
{
	if (_isPreparing)
	{
		NSLog(@"cyclic %@",self);
		return NO;
	}

	_isPreparing = YES;

	int i;
	BOOL ret = NO;
	for (i = 0; i < _pairCount; i++)
	{
		ret |= [_pairs[i] prepareWithPriority:priority + _priority];
	}

	_isPreparing = NO;

	return ret;
}

@end

@implementation TMPort
- (id) initWithPriority:(NSInteger)priority
{
	[self init];
	_priority = priority;
	return self;
}

- (id) init
{
	return self;
}

- (void) dealloc
{
	free(_pairs);
	[super dealloc];
}

- (NSUInteger) priority
{
	return _priority;
}


- (NSString *) description
{
	return [NSString sringWithFormat:@"%@ on %@ priority:%d", [self name], __node, _priority];
}

- (NSString *) name
{
	return [__node nameOfPort:self];
}

@end

