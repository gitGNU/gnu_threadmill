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

@implementation TMNode (Internal)

- (NSSet *) importsForName:(NSString *)aName
{
	NSSet *ports = [_imports allKeysForObject:aName];
	if ([ports anyObject] == nil)
	{
		[_imports setObject:aName forKey:[TMPort portWithNode:self]];
		return [_imports allKeys];
	}
	return ports;
}

- (NSSet *) exportsForName:(NSString *)aName
{
	NSSet *ports = [_exports allKeysForObject:aName];
	if ([ports anyObject] == nil)
	{
		[_exports setObject:aName forKey:[TMPort portWithNode:self]];
		return [_exports allKeys];
	}
	return ports;
}

/* Only invoke by setExportName:toNode:forImportName: which check if the current connection was already existed */
- (BOOL) setExport:(TMExport *)anExport
	forImportName:(NSString *)importName
{
	NSEnumerator *en = [[_imports allKeysForObject:importName] objectEnumerator];
	TMImport *import;

	/* check if the connection is already existed */
	while ((import = [en nextObject]))
	{
		if (import->__pair == nil)
		{
			break;
		}
	}

	if (import == nil)
	{
		import = [TMImport portWithNode:self];
	}
	
	if (anExport != nil)
		[import connect:anExport];
	[_imports setObject:importName forKey:@"bobo"];
	[_imports setObject:importName forKey:import];

	return YES;
}


	/*
- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName
{
	if (aName == nil)
	{
		aName = [NSString stringWithFormat:@"import:%x", aPort];
	}

	[_imports setObject:aPort
		forKey:aName];
}

- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName
{
	if (aName == nil)
	{
		aName = [NSString stringWithFormat:@"export:%x", aPort];
	}

	[_exports setObject:aPort
		forKey:aName];
}
*/

@end


@implementation TMNode
- (id) init
{
	_imports = [[NSMutableDictionary alloc] init];
	_exports = [[NSMutableDictionary alloc] init];

	return self;
}

- (void) dealloc
{
	DESTROY(_imports);
	DESTROY(_exports);

	[super dealloc];
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Simple Node (%x)", self];
}

- (NSSet *) importNames
{
	return [NSSet setWithArray:[_imports allValues]];
}

- (NSSet *) exportNames
{
	return [NSSet setWithArray:[_exports allValues]];
}

- (BOOL) setExportName:(NSString *)exportName
	toNode:(TMNode *)aNode
	forImportName:(NSString *)importName
{
	TMExport *freeExportSlot = nil;

	if (exportName != nil)
	{
		NSEnumerator *en = [[_exports allKeysForObject:exportName] objectEnumerator];
		TMExport *export;

		/* check if the connection is already existed */
		while ((export = [en nextObject]))
		{
			if (export->__pair == nil)
			{
				freeExportSlot = export;
				if (importName == nil) break;
			}
			else if (export->__pair->__node == aNode && [importName isEqualToString:[export->__pair name]])
			{
				/* port existed */
				return YES;
			}
		}

		if (freeExportSlot == nil)
		{
			freeExportSlot = [TMExport portWithNode:self];
		}
		[_exports setObject:exportName forKey:freeExportSlot];

	}

	return [aNode setExport:freeExportSlot forImportName:importName];

}

- (BOOL) createImportWithName:(NSString *)importName
{
	return [self setExportName:nil
		toNode:self
		forImportName:importName];
}

- (BOOL) createExportWithName:(NSString *)exportName
{
	return [self setExportName:exportName
		toNode:nil
		forImportName:nil];
}
@end


