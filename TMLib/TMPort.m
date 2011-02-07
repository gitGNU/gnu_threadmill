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

- (BOOL) connect: (TMPort *)aPair
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

- (void) finishPreparation
{
	[__node finishPreparation];
}

- (void) finishPreparationDependency
{
	int i = 0;
	while (i < _pairs_n)
	{
		[[_pairs[i] finishPreparation];
		i++;
	}
}

/* for export port only */
- (BOOL) addDependant: (NSOperation *)dependant
		 info: (NSDictionary *)operationInfo
{
	NSOperation *exportOp = [__node operationForExportingToPort:self];
	if (![[dependant dependencies] containsObject:exportOp])
	{
		[dependant addDependency:exportOp
			info:operationInfo];
		return YES;
	}
	return NO;
}


/* set and assign */
/* for import port only */
- (void) setDependency: (NSOperation *)dependant
		  info: (NSDictionary *)operationInfo
{
	int i = 0;
	while (i < _pairs_n)
	{
		[[_pairs[i] addDependant:dependant info:operationInfo];
		i++;
	}
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

