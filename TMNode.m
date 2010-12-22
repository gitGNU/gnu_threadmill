#import "TMNode.h"

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
	return [self description];
}

- (NSArray *) importNames
{
	return [_imports allKeys];
}

- (NSArray *) exportNames
{
	return [_exports allKeys];
}

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

