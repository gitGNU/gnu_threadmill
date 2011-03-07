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
@end

@implementation TMTeePipe

+ (id) tee
{
	return AUTORELEASE([[self alloc] init]);
}

- (id) init
{
	[super init];
	_pipesToRead = [[NSMutableArray alloc] init];
	_pipesToWrite = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(_pipesToRead);
	DESTROY(_pipesToWrite);
	[super dealloc];
}

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

- (NSFileHandle *) fileHandleForReading
{
	NSPipe *pipe = [NSPipe pipe];
	[_pipesToWrite addObject:pipe];
	return [pipe fileHandleForReading];
}

- (NSFileHandle *) fileHandleForWriting
{
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *handle = [pipe fileHandleForWriting];

	[self addSource:pipe];
	return handle;
}

- (void) closeHandle: (NSFileHandle *)handle
{
	/* remove the handle from listening list */
	[[NSNotificationCenter defaultCenter] removeObserver: self
							name: NSFileHandleDataAvailableNotification
						      object: handle];

	NSEnumerator *en = [_pipesToRead objectEnumerator];
	id pipeOrHandle;
	while ((pipeOrHandle = [en nextObject]))
	{
		if (pipeOrHandle == handle ||
				([pipeOrHandle isKindOfClass:[NSPipe class]] &&
				 handle == [(NSPipe *)pipeOrHandle fileHandleForReading]))
		{
			break;
		}
	}

	if (pipeOrHandle != nil)
	{
		[_pipesToRead removeObject:pipeOrHandle];

		/* No read pipe left, just close all write */
		if ([_pipesToRead count] == 0)
		{
			en = [_pipesToWrite objectEnumerator];
			while ((pipeOrHandle = [en nextObject]))
			{
				if ([pipeOrHandle isKindOfClass:[NSPipe class]])
				{
					[[(NSPipe *)pipeOrHandle fileHandleForWriting] closeFile];
				}
				else
				{
					[(NSFileHandle *)pipeOrHandle closeFile];
				}
			}
			[_pipesToWrite removeAllObjects];
		}
	}
}

- (void) writeData: (NSData *)data
{
	NSEnumerator *en = [_pipesToWrite objectEnumerator];
	id pipeOrHandle;
	while ((pipeOrHandle = [en nextObject]))
	{
		if ([pipeOrHandle isKindOfClass:[NSPipe class]])
		{
			[[(NSPipe *)pipeOrHandle fileHandleForWriting] writeData:data];
		}
		else [(NSFileHandle *)pipeOrHandle writeData:data];
	}
}

- (void) receivedData: (NSNotification *)not
{
	NSFileHandle * handle = [not object];
	NSData *data = [handle availableData];

	if ([data length] == 0)
	{
		[self closeHandle:handle];
		return;
	}

	[self writeData:data];

	[handle waitForDataInBackgroundAndNotify];
}

- (void) addSource: (id)pipeOrHandle
{
	NSFileHandle * handle;
	if ([pipeOrHandle isKindOfClass:[NSPipe class]])
	{
		handle = [pipeOrHandle fileHandleForReading];
	}
	else handle = pipeOrHandle;

	[[NSNotificationCenter defaultCenter] addObserver: self
						 selector: @selector(receivedData:)
						     name: NSFileHandleDataAvailableNotification
						   object: handle];
	[handle waitForDataInBackgroundAndNotify];

	[_pipesToRead addObject:pipeOrHandle];
}

- (void) addTarget: (id)pipeOrHandle
{
	[_pipesToWrite addObject:pipeOrHandle];
}

- (void) pipeTeeForWriting: (TMTeePipe *)tee
{
	NSPipe *pipe = [NSPipe pipe];
	[_pipesToWrite addObject:pipe];
	[tee addSource:pipe];
}

- (void) pipeTeeForReading: (TMTeePipe *)tee
{
	[tee pipeTeeForWriting:self];
}
@end

