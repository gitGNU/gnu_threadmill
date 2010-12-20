#import "TMNode.h"

@implementation TMNode
- (id) init
{
	_imports = [[NSMutableDictionary alloc] alloc];
	_exports = [[NSMutableDictionary alloc] alloc];

	return self;
}

- (void) dealloc
{
	DESTROY(_imports);
	DESTROY(_exports);

	[super dealloc];
}

- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName
{
	if (aName == nil)
	{
		ASSIGN(aName, [aPort description]);
	}

	[_imports setObject:aPort
		forKey:aName];
}

- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName
{
	if (aName == nil)
	{
		ASSIGN(aName, [aPort description]);
	}

	[_exports setObject:aPort
		forKey:aName];
}

@end

