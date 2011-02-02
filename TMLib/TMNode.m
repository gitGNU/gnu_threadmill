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

#import "TMNodeInternal.h"
#import "TMPortInternal.h"

@implementation TMNode (Internal)

- (NSString *) nameOfPort:(TMPort *)aPort
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (TMPort *) importForName:(NSString *)importName
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (TMPort *) exportForName:(NSString *)exportName
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (NSArray *) importPorts
{
	[self subclassResponsibility: _cmd];
	return nil;
}

- (NSArray *) exportPorts
{
	[self subclassResponsibility: _cmd];
	return nil;
}

@end


@implementation TMNode

+ (id) nodeWithImports:(NSArray *)importList
		exports:(NSArray *)exportList
{
	if ([self isMemberOfClass:[TMNode class]])
		return AUTORELEASE([[TMSimpleNode alloc] initWithImports:importList exports:exportList]);
	else return AUTORELEASE([[self alloc] initWithImports:importList exports:exportList]);
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Simple Node (%x)", self];
}

- (NSArray *) imports
{
	[self subclassResponsibility: _cmd];
	return [NSArray array];
}

- (NSArray *) exports
{
	[self subclassResponsibility: _cmd];
	return [NSArray array];
}

- (BOOL) setExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode
{
	[self subclassResponsibility: _cmd];
	return NO;
}

- (BOOL) removeExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode
{
	[self subclassResponsibility: _cmd];
	return NO;
}

- (NSUInteger) priority
{
	[self subclassResponsibility: _cmd];
	return 0;
}

/* data may already be stored or can be self generated */
- (BOOL) needsImportFromPort:(TMPort *)importPort
{
	[self subclassResponsibility: _cmd];
	return 0;
}

- (NSOperation *) prepareDirection: (TMDirection)direction
	     withPriority: (NSInteger)priority
{
	NSInteger majorPriority = [self priority];
	NSEnumerator *en = [[self importPorts] objectEnumerator];
	TMPort *import;

	NSInvocationOperation *operation;
	

	while ((import = [en nextObject]))
	{
		if (![import prepareDirection:direction
				 withPriority:majorPriority + priority]) &&
			[self needsImportFromPort:import]
		{
			return NO;
		}
	}

	return YES; /* node is fully prepared */
}

- (void) receivedResult: (void *)result
		 ofType: (NSString *)type
	       fromPort: (TMPort *)importPort
{
	[self subclassResponsibility: _cmd];
}

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
	DESTROY(_imports);
	DESTROY(_exports);

	[super dealloc];
}

- (BOOL) createImportWithName:(NSString *)importName
{
	[_imports setObject:[TMPort portForNode:self]
		forKey:importName];
	return YES;
}

- (BOOL) createExportWithName:(NSString *)exportName
{
	[_exports setObject:[TMPort portForNode:self]
		forKey:exportName];
	return YES;
}

- (NSString *) nameOfPort:(TMPort *)aPort
{
	NSString *ret = nil;
	ret = [[_imports allKeysForObject:aPort] lastObject];
	if (ret == nil)
		ret = [[_exports allKeysForObject:aPort] lastObject];
	return ret;
}

- (TMPort *) importForName:(NSString *)importName
{
	return [_imports objectForKey:importName];
}

- (TMPort *) exportForName:(NSString *)exportName
{
	return [_exports objectForKey:exportName];
}

- (NSArray *) imports
{
	return [_imports allKeys];
}

- (NSArray *) exports
{
	return [_exports allKeys];
}

- (BOOL) setExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode
{
	TMPort *export = [_exports objectForKey:exportName];
	TMPort *import = [aNode importForName:importName];
	return [export connect:import];
}

- (BOOL) removeExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode
{
	TMPort *export = [_exports objectForKey:exportName];
	TMPort *import = [aNode importForName:importName];
	return [export connect:import];
}

- (NSArray *) importPorts
{
	return [_imports allValues];
}

- (NSArray *) exportPorts
{
	return [_exports allValues];
}

@end
