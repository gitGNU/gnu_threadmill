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

#import "TMConnector.h"
@interface TMConnector (Private)
- (NSOperation *) dependencyForQueue: (NSOperationQueue *)queue
			       order: (NSDictionary *)operationInfo;
- (void) finishNodeForOrder: (NSDictionary *)opOrder;
- (void) finishOrder: (NSDictionary *)opOrder;
@end

@implementation TMConnector

+ (id) connectorForNode:(TMNode *)aNode
{
	TMConnector *retConnector = [[TMConnector alloc] init];
	AUTORELEASE(retConnector);

	retConnector->__node = aNode;

	return retConnector;
}

- (void) disconnect:(TMConnector *)aPair
{
	int i = 0, j = 0;
	while (i < _pairs_n)
	{
		if (_pairs[i] != aPair)
		{
			_pairs[j] = _pairs[i];
			j++;
		}
		i++;
	}

	if (j < _pairs_n)
	{
		_pairs_n = j;
		[aPair disconnect: self];
	}

}

- (BOOL) connect: (TMConnector *)aPair
{
	int i = 0;
	while (i < _pairs_n)
	{
		if (_pairs[i] == aPair)
		       	return YES;
		i++;
	}

	_pairs_n++;
	_pairs = realloc(_pairs, sizeof(id) * _pairs_n);
	_pairs[_pairs_n - 1] = aPair;

	if (![aPair connect:self])
	{
		_pairs_n--;
		_pairs = realloc(_pairs, sizeof(id) * _pairs_n);
		return NO;
	}

	return YES;
}

- (void) finishNodeForOrder: (NSDictionary *)opOrder
{
	[__node finishOrder:opOrder];
}

- (void) finishOrder: (NSDictionary *)opOrder
{
	int i = 0;
	while (i < _pairs_n)
	{
		[_pairs[i] finishNodeForOrder:opOrder];
		i++;
	}
}

- (NSOperation *) dependencyForQueue: (NSOperationQueue *)queue
			       order: (NSDictionary *)operationInfo
{
	return [__node connectorDependency:self forQueue:queue order:operationInfo];
}

/* set and assign */
/* for import connector only */
- (void) setDependant: (NSOperation *)dependant
	     forQueue: (NSOperationQueue *)queue
		order: (NSDictionary *)opOrder
{
	NSArray *dependencies = [dependant dependencies];
	int i = 0;
	while (i < _pairs_n)
	{
		NSOperation *exportOp = [_pairs[i] dependencyForQueue:queue order:opOrder];
		if (exportOp != nil && ![dependencies containsObject:exportOp])
		{
			[dependant addDependency:exportOp];
			dependencies = [dependant dependencies];
		}
		i++;
	}
}

/*
- (id) initWithPriority:(NSInteger)priority
{
	[self init];
	_priority = priority;
	return self;
}
*/

- (id) init
{
	return self;
}

- (void) dealloc
{
	free(_pairs);
	[super dealloc];
}

- (NSString *) description
{
	return [self name];
}

- (NSString *) name
{
	return [__node nameOfConnector:self];
}

@end

