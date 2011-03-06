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

NSString * const TMStandardInputPort = @"stdin";
NSString * const TMStandardOutputPort = @"stdout";
NSString * const TMStandardErrorPort = @"stderr";

@interface TMTaskOperation : TMOperation
{
/* @package here */
@public
	NSTask *_task;
	NSPipe *_inPipe;
	NSPipe *_outPipe;
	NSPipe *_errPipe;
}
@end

@implementation TMTaskOperation
- (id) initWithTask: (NSTask *)aTask
{
	ASSIGN(_task, aTask);
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
- (id) initWithLaunchPath: (NSString *)launchPath
		arguments: (NSArray *)arguments
{
	[super init];
	ASSIGN(_launchPath, launchPath);
	ASSIGN(_arguments, arguments);
	return self;
}

- (void) dealloc
{
	DESTROY(_launchPath);
	DESTROY(_arguments);
	DESTROY(_inCon);
	DESTROY(_outCon);
	DESTROY(_errCon);
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

/* no queue, it was born finished! */
- (void) queue: (NSOperationQueue *)queue
     operation: (NSOperation *)op
      forOrder: (NSDictionary *)opOrder
{
}

/* connectors */
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
@end

