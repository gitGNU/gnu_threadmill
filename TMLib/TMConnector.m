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
- (void) nodeFinishOrder: (NSDictionary *)order;
- (void) nodePushQueue: (NSOperationQueue *)queue
	      forOrder: (NSDictionary *)order;
- (NSOperation *) dependencyForQueue: (NSOperationQueue *)queue
			       order: (NSDictionary *)operationInfo;
- (NSMethodSignature *) nodeMethodSignatureForSelector: (SEL)aSel;
- (void) nodeForwardInvocation: (NSInvocation *)invocation;
//- (TMConnector *) _nextPair;
@end

@implementation TMConnector

+ (id) connectorForNode: (TMNode *)aNode
		   port: (NSString *)name;
{
	TMConnector *retConnector = [[self alloc] init];
	AUTORELEASE(retConnector);

	retConnector->__node = aNode;
	retConnector->__port = name;

	return retConnector;
}

- (TMNode *) node
{
	return __node;
}

- (NSArray *) allPairs
{
	return [NSArray arrayWithObjects:_pairs count:_pairs_n];
}

/*
- (TMConnector *) _nextPair
{
	if (_pairs_n == 0)
	{
		return nil;
	}

	NSUInteger retPair = _current_pair;

	_current_pair++;
	if (_current_pair >= _pairs_n)
	{
		_current_pair = 0;
	}

	return _pairs[retPair];
}
*/

/* connecting */
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

/* finishing */
- (void) nodeFinishOrder: (NSDictionary *)order
{
	[__node finishOrder:order];
}

- (void) finishOrder: (NSDictionary *)order
{
	int i = 0;
	while (i < _pairs_n)
	{
		[_pairs[i] nodeFinishOrder:order];
		i++;
	}
}

/* pushing */
- (void) nodePushQueue: (NSOperationQueue *)queue
	      forOrder: (NSDictionary *)order
{
	[__node pushQueue:queue forOrder:order];
}

- (void) pushQueue: (NSOperationQueue *) queue
	  forOrder: (NSDictionary *)order
{
	int i = 0;
	while (i < _pairs_n)
	{
		[_pairs[i] nodePushQueue:queue forOrder:order];
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
		order: (NSDictionary *)order
{
	NSArray *dependencies = [dependant dependencies];
	int i = 0;
	while (i < _pairs_n)
	{
		NSOperation *exportOp = [_pairs[i] dependencyForQueue:queue order:order];
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
	return [self port];
}

- (NSString *) port
{
	return __port;
}

/* forwarder */

- (NSMethodSignature *) nodeMethodSignatureForSelector: (SEL)aSel
{
	return [__node methodSignatureForSelector:aSel];
}

- (NSMethodSignature *) methodSignatureForSelector: (SEL)aSel
{
	return [_pairs[0] nodeMethodSignatureForSelector:aSel];
}

- (void) nodeForwardInvocation: (NSInvocation *)invocation
{
	[invocation invokeWithTarget:__node];
}

- (void) forwardInvocation: (NSInvocation *)invocation
{
	/*
	NSUInteger cp = _current_pair;
	SEL aSel = [invocation selector]
	NSMethodSignature * sig = [invocation methodSignature];
	while (![[_pair[_current_pair] nodeMethodSignatureForSelector:aSel] isEqual:sig])
	{
		[self nextPair];
		if (_current_pair == cp) return;
	}
	*/

/* NOTE, this is a bad idea, should just use something fast enumeration */
/* FIXME, make sure the return size are equal */
	int i = 1;
	while (i < _pairs_n)
	{
/*
		SEL aSel = [invocation selector];
		NSMethodSignature *sig = [_pair[i] nodeMethodSignatureForSelector:aSel];
		NSInvocation *inv_copy = [[NSInvocation alloc] initWithMethodSignature:sig];
*/
		
		[_pairs[i] nodeForwardInvocation:invocation];
		i++;
	}
}

/*
- (BOOL) nodeRespondsToSelector: (SEL)aSel
{
	return [__node respondsToSelector:aSel];
}

- (BOOL) respondsToSelector: (SEL)aSel
{
	int i = 0;
	while (i < _pairs_n)
	{
		if ([_pairs[i] nodeRespondsToSelector:aSel])
		{
			return YES;
		}
		i++;
	}
	return NO;
}
*/

@end

