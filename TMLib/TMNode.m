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
#import "TMOperation.h"

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

static NSMutableDictionary	*tmDefaultOpOrder = nil;

@implementation TMNode (Internal)
+ (void) initialize
{
	if (self == [TMNode class])
	{
		tmDefaultOpOrder = [[NSMutableDictionary alloc] init];
		[tmDefaultOpOrder setObject:@"TMDefaultOperationOrder" forKey:@"Name"];
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

/* This should setup KVO monitoring and such */
- (NSOperation *) operationForOrder: (NSDictionary *)order
{
	Class opClass = [self operationClass];
	TMOperation *retOp = [opClass alloc];
	
	if ([opClass isKindOfClass:[TMOperation class]])
	{
		[retOp initWithOrder:order];
	}
	else [retOp init];

	return [retOp autorelease];
}

- (void) queue: (NSOperationQueue *)queue
     operation: (NSOperation *)op
      forOrder: (NSDictionary *)opOrder
{
	if (queue != nil)
	{
		[queue addOperation:op];
	}
}

/* Override connectorDependency:forQueue:order: to implement subdependencies, eg. eA,eB depend on iA
   and eC depends on iB or define an export that isn't depending on any import.

   This method may be invoked more than once. To prevent cyclic dependencies,
   it makes sure that the method won't be invoked while fetching dependencies.

   nodeA connectorDependency:forQueue:order: ->
   foreach (nodeA->imports) import setDependant:forQueue:order: ->
      foreach (import->exports) export dependencyForQueue:order: ->
        export->nodeN connectorDependency:forQueue:order: -> and so on

   Note: a single port may be connected with more than one port,
   All linked exports will be added as dependencies for each import. */

/* FIXME queue:forConnector:order:*/
- (NSOperation *) connectorDependency: (TMConnector *)exportConnector
			     forQueue: (NSOperationQueue *)queue
				order: (NSDictionary *)opOrder
{
	if (opOrder == nil) opOrder = tmDefaultOpOrder;

	//NSOperation *op = [_orders objectForKey:opOrder];
	NSOperation *op = [_orders objectForKey:opOrder];

	/* no op is being prepared, so create one */
	if (op  == nil)
	{
		op = [self operationForOrder:opOrder];

		[_preps addObject:op];
		[_orders setObject:op forKey:opOrder];

			/* FIXME synchronize a current search with operation order */
			TMConnector *conn;
			NSEnumerator *en;

			en = [[self allImportConnectors] objectEnumerator];
			while ((conn = [en nextObject]))
			{
				[conn setDependant:op
					  forQueue:queue
					     order:opOrder];
			}

		[_preps removeObject:op];

		[self queue:queue operation:op forOrder:opOrder];


	}

	/* Block cyclic dependency, if an op is being prepared,
	   just don't return it. */
	/* TODO Design specific APIs for this preparation methods.

		   - (void) togglePreparationStateOfOperation:(NSOperation *)op;
		   - (BOOL) isPreparingOperation:(NSOperation *)op;

	   may be superclass AbstractNode later. */

	if ([_preps containsObject:op])
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

#if 0
+ (void) setDependant: (NSOperation *)operation
	     forNodes: (NSArray *)nodeList
	        queue: (NSOperationQueue *)queue
	        order: (NSDictionary *)opOrder
{
	NSEnumerator *en = [nodeList objectEnumerator];
	TMNode *node;
	while ((node = [en nextObject]))
	{
		NSOperation *nodeOp = [node connectorDependency:nil forQueue:queue order:opOrder];

		if (nodeOp != nil) [operation addDependency:nodeOp];
	}

	en = [nodeList objectEnumerator];
	while ((node = [en nextObject]))
	{
		[node finishOrder:nil];
	}
}
#endif

- (void) finishOrder: (NSDictionary *)opOrder
{
	if (opOrder == nil) opOrder = tmDefaultOpOrder;

	NSOperation *op = [_orders objectForKey:opOrder];

	if (op != nil)
	{
		[_orders removeObjectForKey:opOrder];

		TMConnector *con;
		NSEnumerator *en;

		en = [[self allImportConnectors] objectEnumerator];
		while ((con = [en nextObject]))
		{
			[con finishOrder:opOrder];
		}

		en = [[self allExportConnectors] objectEnumerator];
		while ((con = [en nextObject]))
		{
			[con finishOrder:opOrder];
		}
	}
}


- (void) pushQueue: (NSOperationQueue *)queue
	  forOrder: (NSDictionary *)opOrder
{
	NSEnumerator *en = [[self allExportConnectors] objectEnumerator];
	TMConnector *export;

	export = [en nextObject];
	do {
		[self connectorDependency:export
				 forQueue:queue
				    order:opOrder];
		if (export != nil)
			[export pushQueue:queue
				 forOrder:opOrder];
	} while ((export = [en nextObject]));
}

- (id) init
{
	_orders = [[NSMutableDictionary alloc] init];
	_preps = [[NSMutableSet alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(_orders);
	DESTROY(_preps);
	[super dealloc];
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Abstract node (%x)", self];
}

- (Class) operationClass
{
	return [TMOperation class];
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
	return [NSArray array];
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
	_opClass = [super operationClass];

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

- (void) setOperationClass: (Class)aClass
{
	_opClass = aClass;
}

- (Class) operationClass
{
	return _opClass;
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Generic node (%x)", self];
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
