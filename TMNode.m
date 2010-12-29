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

#import "TMNode.h"

@interface TMNode (Private)
- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName;
- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName;
@end

@implementation TMNode (Private)
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

- (NSArray *) importNames
{
	return [_imports allKeys];
}

- (NSArray *) exportNames
{
	return [_exports allKeys];
}

@end

