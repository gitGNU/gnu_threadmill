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

#import <Foundation/NSOperation.h>
#import "TMNodeInternal.h"
#import "TMConnector.h"

@implementation TMNode (Internal)

- (NSString *) nameOfConnector:(TMConnector *)aConnector
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (TMConnector *) connectorForImport:(NSString *)importName
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (TMConnector *) connectorForExport:(NSString *)exportName
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (NSArray *) allImportConnectors
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (NSArray *) allExportConnectors
{
	[self subclassResponsibility: _cmd];
	return nil;
}

/* Remove all properties in preparation processes. */
/* If connectorDependency:info: is overridden,
   make sure you override this to free all data used in preparation process */
- (void) finishPreparation
{
	if (_nodeOperation != nil)
	{
		DESTROY(_nodeOperation);

		TMConnector *iconn;
		NSEnumerator *en;

		en = [[self allImportConnectors] objectEnumerator];
		while ((iconn = [en nextObject]))
		{
			[iconn finishDependencyPreparation];
		}
	}
}

/* Override connectorDependency:info: and isPreparingDependency:info:
   or use the delegate to implement subdependencies, eg. eA,eB depend
   on iA and eC depends on iB or define an export that isn't depending on any import.

   This method may be invoked more than once. To prevent cyclic dependencies,
   it makes sure that the method won't be invoked while fetching dependencies
   using -isPreparingDependencies:info:.

   nodeA connectorDependency:info: ->
   for (nodeA->imports) import setDependant:info: ->
      for (import->exports) export depencyWithInfo: ->
        export->nodeN connectorDependency:info: -> and so on

   Note: a single port may be connected with more than one port,
   All linked exports will be added as dependencies for each import. */

- (NSOperation *) connectorDependency: (TMConnector *)aConnector
				 info: (NSDictionary *)operationInfo
{
	if (_nodeOperation == nil)
	{
		_isPreparingDependencies = YES;

		_nodeOperation = [[NSOperation alloc] init]; //FIXME
		TMConnector *conn;
		NSEnumerator *en;

		en = [[self allImportConnectors] objectEnumerator];
		while ((conn = [en nextObject]))
		{
			[conn setDependant:_nodeOperation
				info:operationInfo];
		}

		_isPreparingDependencies = NO;
	}

	if ([self isPreparingDependency:aConnector info:operationInfo])
	{
		return nil;
	}

	return _nodeOperation;
}

- (BOOL) isPreparingDependency: (TMConnector *)aConnector
			  info: (NSDictionary *)operationInfo
{
	return _isPreparingDependencies;
}


@end


@implementation TMNode

+ (id) nodeWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList
{
	if ([self isMemberOfClass:[TMNode class]])
		return AUTORELEASE([[TMSimpleNode alloc] initWithImports:importList exports:exportList]);
	else return AUTORELEASE([[self alloc] initWithImports:importList exports:exportList]);
}

+ (void) setDependant: (NSOperation *)operation
	     forNodes: (NSArray *)nodeList
	         info: (NSDictionary *)operationInfo
{
	NSEnumerator *en = [nodeList objectEnumerator];
	TMNode *node;
	while ((node = [en nextObject]))
	{
		NSOperation *nodeOp = [node connectorDependency:nil info:operationInfo];

		if (nodeOp != nil) [operation addDependency:nodeOp];
	}

	en = [nodeList objectEnumerator];
	while ((node = [en nextObject]))
	{
		[node finishPreparation];
	}
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Simple Node (%x)", self];
}

- (NSArray *) allImports
{
	[self subclassResponsibility: _cmd];
	return [NSArray array];
}

- (NSArray *) allExports
{
	[self subclassResponsibility: _cmd];
	return [NSArray array];
}

- (BOOL) setExport: (NSString *)exportName
	 forImport: (NSString *)importName
	    onNode: (TMNode *)aNode
{
	[self subclassResponsibility: _cmd];
	return NO;
}

- (void) removeExport: (NSString *)exportName
	    forImport: (NSString *)importName
	       onNode: (TMNode *)aNode
{
	[self subclassResponsibility: _cmd];
}

/*
- (NSUInteger) priority
{
	[self subclassResponsibility: _cmd];
	return 0;
}
*/

/*
- (void) receivedResult: (void *)result
		 ofType: (NSString *)type
	       fromPort: (TMConnector *)importPort
{
	[self subclassResponsibility: _cmd];
}
*/

@end

@implementation TMSimpleNode
- (id) init
{
	_imports = [[NSMutableDictionary alloc] init];
	_exports = [[NSMutableDictionary alloc] init];

	return [super init];
}

- (id) initWithImports:(NSArray *)importList
	       exports:(NSArray *)exportList
{
	[self init];

	NSEnumerator *en = [importList objectEnumerator];
	NSString *portName;

	while ((portName = [en nextObject]))
	{
		[self createImportWithName:portName];
	}

	en = [exportList objectEnumerator];

	while ((portName = [en nextObject]))
	{
		[self createExportWithName:portName];
	}

	return self;
}

- (void) dealloc
{
	DESTROY(_nodeOperation);
	DESTROY(_imports);
	DESTROY(_exports);

	[super dealloc];
}

- (BOOL) createImportWithName:(NSString *)importName
{
	[_imports setObject:[TMConnector connectorForNode:self]
		     forKey:importName];
	return YES;
}

- (BOOL) createExportWithName:(NSString *)exportName
{
	[_exports setObject:[TMConnector connectorForNode:self]
		     forKey:exportName];
	return YES;
}

- (NSString *) nameOfConnector:(TMConnector *)aConnector
{
	NSString *ret = nil;
	ret = [[_imports allKeysForObject:aConnector] lastObject];
	if (ret == nil)
		ret = [[_exports allKeysForObject:aConnector] lastObject];
	return ret;
}

- (TMConnector *) connectorForImport:(NSString *)importName
{
	return [_imports objectForKey:importName];
}

- (TMConnector *) connectorForExport:(NSString *)exportName
{
	return [_exports objectForKey:exportName];
}

- (NSArray *) allImports
{
	return [_imports allKeys];
}

- (NSArray *) allExports
{
	return [_exports allKeys];
}

- (BOOL) setExport:(NSString *)exportName
	 forImport:(NSString *)importName
	    onNode:(TMNode *)aNode
{
	TMConnector *import = [aNode connectorForImport:importName];
	TMConnector *export = [_exports objectForKey:exportName];
	return [export connect:import];
}

- (void) removeExport:(NSString *)exportName
	    forImport:(NSString *)importName
	       onNode:(TMNode *)aNode
{
	TMConnector *export = [_exports objectForKey:exportName];
	TMConnector *import = [aNode connectorForImport:importName];
	[export disconnect:import];
}

- (NSArray *) allImportConnectors
{
	return [_imports allValues];
}

- (NSArray *) allExportConnectors
{
	return [_exports allValues];
}

@end
