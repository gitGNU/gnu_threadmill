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
- (void) nodeFinishOrder: (NSDictionary *)opOrder;
- (void) nodePushQueue: (NSOperationQueue *)queue
	      forOrder: (NSDictionary *)opOrder;
- (NSOperation *) dependencyForQueue: (NSOperationQueue *)queue
			       order: (NSDictionary *)operationInfo;
- (NSMethodSignature *) nodeMethodSignatureForSelector: (SEL)aSel;
- (void) nodeForwardInvocation: (NSInvocation *)invocation;
@end

@implementation TMConnector

+ (id) connectorForNode: (TMNode *)aNode
		   port: (NSString *)name;
{
	TMConnector *retConnector = [[TMConnector alloc] init];
	AUTORELEASE(retConnector);

	retConnector->__node = aNode;
	retConnector->__port = name;

	return retConnector;
}

- (NSUInteger) count
{
	return _pairs_n;
}

- (TMNode *) nextPair;
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

	return _pairs[retPair]->__node;
}

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
- (void) nodeFinishOrder: (NSDictionary *)opOrder
{
	[__node finishOrder:opOrder];
}

- (void) finishOrder: (NSDictionary *)opOrder
{
	int i = 0;
	while (i < _pairs_n)
	{
		[_pairs[i] nodeFinishOrder:opOrder];
		i++;
	}
}

/* pushing */
- (void) nodePushQueue: (NSOperationQueue *)queue
	      forOrder: (NSDictionary *)opOrder
{
	[__node pushQueue:queue forOrder:opOrder];
}

- (void) pushQueue: (NSOperationQueue *) queue
	  forOrder: (NSDictionary *)opOrder
{
	int i = 0;
	while (i < _pairs_n)
	{
		[_pairs[i] nodePushQueue:queue forOrder:opOrder];
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
	return [_pairs[_current_pair] nodeMethodSignatureForSelector:aSel];
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

	[[self nextPair] nodeForwardInvocation:invocation];
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

