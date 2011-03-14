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

#import "TMTeePipe.h"

@interface TMTeePipe (Private)
- (void) receivedData: (NSNotification *)not;
- (void) writeData: (NSData *)data;
@end

@implementation TMTeePipe

+ (id) tee
{
	return AUTORELEASE([[self alloc] init]);
}

- (id) init
{
	NSDebugLLog(@"TMTeePipe",@"XX pipe init %@",self);
	[super init];

	_pipesToRead = [[NSMutableArray alloc] init];
	_pipesToWrite = [[NSMutableArray alloc] init];

	return self;
}

- (void) dealloc
{
	NSDebugLLog(@"TMTeePipe",@"XX pipe dealloc %@",self);
	NSEnumerator *en = [_pipesToRead objectEnumerator];
	id pipeOrHandle;
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	while ((pipeOrHandle = [en nextObject]))
	{
		if ([pipeOrHandle isKindOfClass:[NSPipe class]])
			pipeOrHandle = [pipeOrHandle fileHandleForReading];

		NSDebugLLog(@"TMTeePipe",@"%x SOURCE drem %@",self, pipeOrHandle);

		[dc removeObserver:self
			      name:NSFileHandleDataAvailableNotification
			    object:pipeOrHandle];

	}
	DESTROY(_pipesToRead);

	en = [_pipesToWrite objectEnumerator];
	while ((pipeOrHandle = [en nextObject]))
	{
		if ([pipeOrHandle isKindOfClass:[NSPipe class]])
			pipeOrHandle = [pipeOrHandle fileHandleForWriting];

		NSDebugLLog(@"-TMTeePipe",@"%x close %@",self, pipeOrHandle);
		[pipeOrHandle closeFile];
	}
	DESTROY(_pipesToWrite);

	[super dealloc];
}


/* Stop pretending you are a Pipe, for now
- (BOOL) isKindOfClass:(Class)aClass
{
	if ([super isKindOfClass:aClass])
	{
		return YES;
	}
	if (aClass == [NSPipe class])
	{
		return YES;
	}
	return NO;
}
*/

- (NSPipe *) pipeForReading
{
	NSPipe *pipe = [NSPipe pipe];
	[_pipesToWrite addObject:pipe];
	NSDebugLLog(@"TMTeePipe",@"%x--[%x(%x)%x]>>>>",self, [pipe fileHandleForWriting],pipe,[pipe fileHandleForReading]);
	return pipe;
}

- (NSPipe *) pipeForWriting
{
	NSPipe *pipe = [NSPipe pipe];
	NSDebugLLog(@"TMTeePipe",@">>>>[%x(%x)%x]--%x",[pipe fileHandleForWriting],pipe,[pipe fileHandleForReading],self);

	[self addSource:pipe];
	return pipe;
}

- (void) writeData: (NSData *)data
{
	NSEnumerator *en = [_pipesToWrite objectEnumerator];
	id pipeOrHandle;
	while ((pipeOrHandle = [en nextObject]))
	{
		NSDebugLLog(@"TMTeePipe",@"----%x is writing (%d bytes) to %@",self,[data length],pipeOrHandle);
		if ([pipeOrHandle isKindOfClass:[NSPipe class]])
		{
			[[(NSPipe *)pipeOrHandle fileHandleForWriting] writeData:data];
		}
		else
		{
			/* NSFileHandle or TMTeePipe */
			[(TMTeePipe *)pipeOrHandle writeData:data];
		}
	}
}

- (void) removeSource: (id)source
{
	if (![source isKindOfClass:[self class]])
	{

		NSFileHandle * handle;
		if ([source isKindOfClass:[NSPipe class]])
		{
			handle = [source fileHandleForReading];
		}
		else handle = source;

		NSDebugLLog(@"TMTeePipe",@"%x SOURCE rem %@",self, handle);
		[[NSNotificationCenter defaultCenter] removeObserver:self
								name:NSFileHandleDataAvailableNotification
							      object:handle];

	}
	[_pipesToRead removeObject:source];

	if ([_pipesToRead count] > 0)
		return;

	/* No read pipe left, just close all writes */
	NSDebugLLog(@"TMTeePipe",@"%x closes all writes %@",self,_pipesToWrite);
	NSEnumerator *en = [_pipesToWrite objectEnumerator];
	id target;
	while ((target = [en nextObject]))
	{
		NSDebugLLog(@"TMTeePipe",@"  L__%x close %@",self, source);

		if ([target isKindOfClass:[NSPipe class]])
		{
			[[target fileHandleForWriting] closeFile];
		}
		else if ([target isKindOfClass:[NSFileHandle class]])
		{
			[target closeFile];
		}
		else //if ([target isKindOfClass:[self class]])
		{
			[target removeSource:self];
		}

	}
	[_pipesToWrite removeAllObjects];
}

- (void) addSource: (id)source
{
	if (![source isKindOfClass:[self class]])
	{
		NSFileHandle * handle;
		if ([source isKindOfClass:[NSPipe class]])
		{
			handle = [source fileHandleForReading];
		}
		else handle = source;

		NSDebugLLog(@"TMTeePipe",@"%x SOURCE add %@",self, handle);
		[[NSNotificationCenter defaultCenter] addObserver:self
							 selector:@selector(receivedData:)
							     name:NSFileHandleDataAvailableNotification
							   object:handle];
		[handle waitForDataInBackgroundAndNotify];
	}

	[_pipesToRead addObject:source];
}

- (void) addTarget: (id)target
{
	[_pipesToWrite addObject:target];
	[target addSource:self];
}


- (void) receivedData: (NSNotification *)not
{
	NSFileHandle * handle = [not object];
	NSData *data = [handle availableData];

	NSDebugLLog(@"TMTeePipe",@"Tee %x received %d from %@",self, [data length], handle);

	if ([data length] == 0)
	{
		/* remove the handle from listening list */

		[[NSNotificationCenter defaultCenter] removeObserver:self
								name:NSFileHandleDataAvailableNotification
							      object:handle];

		NSDebugLLog(@"TMTeePipe",@"%x SOURCE rem %@",self, handle);

		NSEnumerator *en = [_pipesToRead objectEnumerator];
		id source;
		while ((source = [en nextObject]))
		{
			if (source == handle ||
					([source isKindOfClass:[NSPipe class]] &&
					 handle == [(NSPipe *)source fileHandleForReading]))
			{
				[self removeSource:source];
				break;
			}
		}

		return;
	}
	else [self writeData:data];

	[handle waitForDataInBackgroundAndNotify];
}

@end

