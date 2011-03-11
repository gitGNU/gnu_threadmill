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
//	NSTask *_task;
	NSMutableDictionary *_readTees;
	NSMutableDictionary *_writeTees;
}
@end

@implementation TMTaskOperation

- (id) init
{
	[super init];
	ASSIGN(_readTees, [NSMutableDictionary dictionaryWithCapacity:3]);
	ASSIGN(_writeTees, [NSMutableDictionary dictionaryWithCapacity:3]);
	return self;
}

- (void) dealloc
{
	DESTROY(_readTees);
	DESTROY(_writeTees);
	[super dealloc];
}

/* This op class is just a place holder, it is always finished and it won't be queued. Task-nodes are responsible for launching task */
/* FIXME There should be 2 ops, the launcher and the finisher so the dependants can choose the kind of dependency */ 
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

- (void) taskDidTerminate: (NSNotification *)notification
{
	NSTask *task = [notification object];
	[[NSNotificationCenter defaultCenter]
			removeObserver:taskOp
				  name:NSTaskDidTerminateNotification
				object:task];
}
@end

/*
@interface TMTaskConnector : TMConnector
@end
*/


@implementation TMTaskNode

/*
- (Class) connectorClass
{
	return [TMTaskConnector class];
}
*/

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

	/* FIXME, handle bad names */
	int fd = [import intValue];
	return [NSString stringWithFormat:@"unknown %d", fd]; //Unknown for now
}

- (NSString *) displayNameForExport: (NSString *)export
{
	if ([export isEqualToString:@"1"])
	{
		return @"stdout";
	}
	if ([export isEqualToString:@"2"])
	{
		return @"stderr";
	}

	/* FIXME, handle bad names */
	int fd = [export intValue];
	return [NSString stringWithFormat:@"unknown %d", fd];
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

- (NSString *) description
{
	return [self name];
}

- (NSString *) name
{
	return [NSString stringWithFormat:@"Task \"%@ %@\" (0x%x)",_launchPath,_arguments, self];
}

- (NSString *) launchPath
{
	return _launchPath;
}

- (NSArray *) arguments
{
	return _arguments;
}

- (NSOperation *) createOperationForOrder: (NSDictionary *)order
{
	NSTask * task = AUTORELEASE([[NSTask alloc] init]);
	TMTaskOperation *taskOp = [TMTaskOperation operationForNode:self order:order];
	id tee;

	NSEnumerator *en = [[self allImportConnectors] objectEnumerator];
	TMConnector *conn;
	while ((conn = [en nextObject]))
	{
		NSString *port = [conn port];
		if ([[conn allPairs] count] == 0)
		{
			/* plug */
			tee = [NSFileHandle fileHandleWithNullDevice];
		}
		else
		{
			tee = [TMTeePipe tee];
			[taskOp->_readTees setObject:tee forKey:port];
		}

		/* FIXME GNUstep doesn't want to leave fd more than 2 on open */
		if ([port isEqualToString:@"0"])
		{
			NSDebugLLog(@"TMTaskNode", @"stdin %@",tee);
			[task setStandardInput:tee];

		}
	}

	en = [[self allExportConnectors] objectEnumerator];
	while ((conn = [en nextObject]))
	{
		NSString *port = [conn port];
		if ([[conn allPairs] count] == 0)
		{
			/* plug */
			tee = [NSFileHandle fileHandleWithNullDevice];
		}
		else
		{
			tee = [TMTeePipe tee];
			[taskOp->_writeTees setObject:tee forKey:port];
		}

		if ([port isEqualToString:@"1"])
		{
			NSDebugLLog(@"TMTaskNode", @"stdout %@",tee);
			[task setStandardOutput:tee];
		}
		else if ([port isEqualToString:@"2"])
		{
			NSDebugLLog(@"TMTaskNode", @"stderr %@",tee);
			[task setStandardError:tee];
		}
	}

	[task setLaunchPath:_launchPath];
	[task setArguments:_arguments];

	[[NSNotificationCenter defaultCenter]
			addObserver:taskOp
			   selector:@selector(taskDidTerminate:)
			       name:NSTaskDidTerminateNotification
			     object:task];
	NSDebugLLog(@"TMTaskNode", @"launch %@ %@", _launchPath, _arguments);

	[task launch];

	return AUTORELEASE(taskOp);
}

/* called by remote node */
- (void) pipeTeeForWriting: (TMTeePipe *)remoteTee
		    byPort: (NSString *)port
		  forOrder: (NSDictionary *)order
{
	TMTaskOperation *taskOp = [_opOrders objectForKey:order];
	TMTeePipe *localTee = [taskOp->_writeTees objectForKey:port];

	NSDebugLLog(@"TMTaskNode", @"%@ piping tee %@..", self,port);
	[localTee pipeTeeForWriting:remoteTee];
}


/* FIXME This should actually queue 2 ops, one depends on another.
 * The first one is the launching op and another is the terminator,
 * This would allow dependant to wait for either piping data or
 * complete file generations.
 */

- (void) queue: (NSOperationQueue *)queue
     operation: (NSOperation *)op
      forOrder: (NSDictionary *)order
{
	NSDebugLLog(@"TMTaskNode", @"   in %@ , queue %@",self,op);
	/* setting up tees, on current thread */
	NSEnumerator *en = [[self allImportConnectors] objectEnumerator];
	TMConnector *conn;
	while ((conn = [en nextObject]))
	{
		NSString *port = [conn port];
		TMTeePipe *tee = [((TMTaskOperation *)op)->_readTees objectForKey:port];

		if (tee == nil) continue;

		NSEnumerator *portEn = [[conn allPairs] objectEnumerator];
		TMConnector *pair;
		while ((pair = [portEn nextObject]))
		{
			[(TMTaskNode *)[pair node] pipeTeeForWriting:tee byPort:[pair port] forOrder:order];
			NSDebugLLog(@"TMTaskNode", @"...to %@ on %@",port,self);
		}
	}

	[super queue:queue operation:op forOrder:order];
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

