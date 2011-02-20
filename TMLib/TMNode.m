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

@implementation TMConnecting
+ (id) connectingWithExporter: (TMNode *)exporter
		       export: (NSString *)export
		     importer: (TMNode *)importer
		       import: (NSString *)import
		         type: (TMConnectingType)type
{
	TMConnecting *ret = NSAllocateObject (self, 0, NSDefaultMallocZone());
	[ret autorelease];

	ret->exporter = exporter;
	ret->importer = importer;
	ret->export = export;
	ret->import = import;
	ret->type = type;

	return ret;
}

@end

static NSMutableDictionary *tmDefaultOpInfo = nil;

@implementation TMNode (Internal)
+ (void) initialize
{
	if (self == [TMNode class])
	{
		tmDefaultOpInfo = [NSMutableDictionary dictionary];
		[tmDefaultOpInfo retain];
	}
}


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

#if 0
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
#endif

/* Override connectorDependency:info: to implement subdependencies, eg. eA,eB depend on iA
   and eC depends on iB or define an export that isn't depending on any import.

   This method may be invoked more than once. To prevent cyclic dependencies,
   it makes sure that the method won't be invoked while fetching dependencies.

   nodeA connectorDependency:info: ->
   for (nodeA->imports) import setDependant:info: ->
      for (import->exports) export depencyWithInfo: ->
        export->nodeN connectorDependency:info: -> and so on

   Note: a single port may be connected with more than one port,
   All linked exports will be added as dependencies for each import. */

- (NSOperation *) connectorDependency: (TMConnector *)exportConnector
				 info: (NSDictionary *)operationInfo
{
	if (operationInfo == nil) operationInfo = tmDefaultOpInfo;

	NSOperation *op = [_opInfos objectForKey:operationInfo];

	/* no op is being prepared, so create one */
	if (op  == nil)
	{
		op = [[NSOperation alloc] init]; //FIXME

		[_preparingOps addObject:op];
		[_opInfos setObject:op forKey:operationInfo];

		/* FIXME synchronize a current search with operation info */
		TMConnector *conn;
		NSEnumerator *en;

		en = [[self allImportConnectors] objectEnumerator];
		while ((conn = [en nextObject]))
		{
			[conn setDependant:op
				      info:operationInfo];
		}

		[_preparingOps removeObject:op];
	}

	/* Block cyclic dependency, if an op is being prepared, just don't return it. */
	/* TODO Design specific APIs for this. -setPreparing:(BOOL) forOp:(Op), -isPreparingOp:(Op), +(Op) op,
	   may be superclass AbstractNode later. */

	if ([_preparingOps containsObject:op])
	{
		return nil;
	}

	return op;
}


@end


@implementation TMNode

+ (id) nodeWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList
{
	if ([self isMemberOfClass:[TMNode class]])
		return AUTORELEASE([[TMGenericNode alloc] initWithImports:importList exports:exportList]);
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

- (id) init
{
	_opInfos = [[NSMutableDictionary alloc] init];
	_preparingOps = [[NSMutableSet alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(_opInfos);
	DESTROY(_preparingOps);
	[super dealloc];
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Generic Node (%x)", self];
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

- (NSArray *) setExport: (NSString *)exportName
	      forImport: (NSString *)importName
	         onNode: (TMNode *)aNode
	            try: (BOOL)try
{
	[self subclassResponsibility: _cmd];
	return [NSArray array];
}

- (NSArray *) removeExport: (NSString *)exportName
		 forImport: (NSString *)importName
		    onNode: (TMNode *)aNode
		       try: (BOOL)try
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

@implementation TMGenericNode
- (id) init
{
	[super init];
	_imports = [[NSMutableDictionary alloc] init];
	_exports = [[NSMutableDictionary alloc] init];

	return self;
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

- (NSArray *) setExport: (NSString *)exportName
	      forImport: (NSString *)importName
	         onNode: (TMNode *)aNode
	            try: (BOOL)try
{

	if (try)
	{
		return [NSArray arrayWithObject:[TMConnecting connectingWithExporter:self
                                                			      export:exportName
                                                			    importer:aNode
                                                			      import:importName
                                                			        type:TMConnectingTypeSetExport]];
	}

	TMConnector *import = [aNode connectorForImport:importName];
	TMConnector *export = [_exports objectForKey:exportName];
	if ([export connect:import])
	{
		return [NSArray arrayWithObject:[TMConnecting connectingWithExporter:self
                                                			      export:exportName
                                                			    importer:aNode
                                                			      import:importName
                                                			        type:TMConnectingTypeSetExport]];
	}
	else return [NSArray array];
}

- (NSArray *) removeExport: (NSString *)exportName
		 forImport: (NSString *)importName
		    onNode: (TMNode *)aNode
		       try: (BOOL)try
{
	if (try)
	{
		return [NSArray arrayWithObject:[TMConnecting connectingWithExporter:self
                                                			      export:exportName
                                                			    importer:aNode
                                                			      import:importName
                                                			        type:TMConnectingTypeRemoveExport]];
	}

	TMConnector *export = [_exports objectForKey:exportName];
	TMConnector *import = [aNode connectorForImport:importName];
	[export disconnect:import];

	return [NSArray arrayWithObject:[TMConnecting connectingWithExporter:self
								      export:exportName
								    importer:aNode
								      import:importName
									type:TMConnectingTypeRemoveExport]];
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
