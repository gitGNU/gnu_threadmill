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

#import "TMTaskNode.h"
#import "TMLib/TMOperation.h"
#import "TMLib/TMConnector.h"
#import "TMLib/TMTeePipe.h"

/*
NSString * const TMStandardInputPort = @"stdin";
NSString * const TMStandardOutputPort = @"stdout";
NSString * const TMStandardErrorPort = @"stderr";
*/

@interface TMTaskOperation : TMOperation
{
/* @package */
@public
	NSTask *_task;
	NSMutableDictionary *_readTees;
	NSMutableDictionary *_outTees;
}
@end

@implementation TMTaskOperation
- (id) initWithTask: (NSTask *)aTask
{
	ASSIGN(_task, aTask);
	ASSIGN(_inTees, [NSMutableDictionary dictionaryWithCapacity:3]);
	ASSIGN(_outTees, [NSMutableDictionary dictionaryWithCapacity:3]);

	return self;
}

- (void) dealloc
{
	DESTROY(_task);
	[super dealloc];
}

/* This op class is just a place holder, it is always finished and it won't be queued. Task-nodes are responsible for launching task */
- (BOOL) isFinished
{
	return YES;
}

/*
- (void) main
{
	[_task performSelectorOnMainThread: @selector(launch) withObject: nil waitUntilDone: NO];
}
*/
@end

@implementation TMTaskNode

+ (id) nodeWithLaunchPath: (NSString *)launchPath
		arguments: (NSArray *)arguments
{
	return AUTORELEASE([[self alloc] initWithLaunchPath:launchPath arguments:arguments]);
}

- (id) initWithLaunchPath: (NSString *)launchPath
		arguments: (NSArray *)arguments
{
	[super init];
	ASSIGN(_launchPath, launchPath);
	ASSIGN(_arguments, arguments);
	[self createImport:@"0"];
	[self createImport:@"1"];
	[self createImport:@"2"];
	[self createExport:@"0"];
	[self createExport:@"1"];
	[self createExport:@"2"];
	return self;
}

- (NSString *) displayNameForImport: (NSString *)import
{
	if ([import isEqualToString:@"0"])
	{
		return @"stdin";
	}
	if ([import isEqualToString:@"1"])
	{
		return @"stdout";
	}
	if ([import isEqualToString:@"2"])
	{
		return @"stderr";
	}

	/* FIXME, handle bad names */
	int fd = [import intValue];
	if (fd >= 3)
	{
		return [NSString stringWithFormat:@"%d", fd];
	}

	return @"unknown";
}

- (NSString *) displayNameForExport: (NSString *)export
{
	return [self displayNameForImport:export];
}

- (void) dealloc
{
	DESTROY(_launchPath);
	DESTROY(_arguments);
	/*
	DESTROY(_inCon);
	DESTROY(_outCon);
	DESTROY(_errCon);
	*/
	[super dealloc];
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Task node (%x)", self];
}

- (NSString *) launchPath
{
	return _launchPath;
}

- (NSArray *) arguments
{
	return _arguments;
}

- (NSOperation *) operationForOrder: (NSDictionary *)order
{
}

/* FIXME This should actually queue 2 ops, one depends on another.
 * The first one is the launching op and another is the terminator,
 * This would allow dependant to wait for either piping data or
 * complete file generations.
 */

- (void) queue: (NSOperationQueue *)queue
     operation: (NSOperation *)op
      forOrder: (NSDictionary *)opOrder
{
	/* setting up tees, on current thread */
	NSEnumerator *en = [[self allImportConnectors] objectEnumerator];
	TMConnector *conn;
	int i;

	while ((conn = [en nextObject]))
	{
		for (i = [conn count]; i; i--)
		{

		}
	}


}

/* connectors */
/*
- (TMConnector *) connectorForImport:(NSString *)importName
{
	if ([importName isEqualToString:TMStandardInputPort])
	       	return _inCon;
}

- (TMConnector *) connectorForExport:(NSString *)exportName
{
	if ([exportName isEqualToString:TMStandardOutputPort])
	       	return _outCon;
	if ([exportName isEqualToString:TMStandardErrorPort])
	       	return _errCon;
}

- (NSArray *) allImportConnectors
{
	return [NSArray arrayWithObject:_inCon];
}

- (NSArray *) allExportConnectors
{
	return [NSArray arrayWithObjects:_outCon,_errCon,nil];
}
*/
@end

