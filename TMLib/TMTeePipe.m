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
- (void) addPipeToRead: (NSPipe *)pipe;
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

	[self addPipeToRead:pipe];
	return handle;
}

- (void) receivedData: (NSNotification *)not
{
	NSFileHandle * handle = [not object];
	NSData *data = [handle availableData];


	if ([data length] == 0)
	{
		/* remove the handle from listening list */
		[[NSNotificationCenter defaultCenter] removeObserver: self
								name: NSFileHandleDataAvailableNotification
							      object: handle];

		NSEnumerator *en = [_pipesToRead objectEnumerator];
		NSPipe *pipe;
		while ((pipe = [en nextObject]))
		{
			if (handle == [pipe fileHandleForReading])
			{
				break;
			}
		}
		if (pipe != nil)
		{
			[_pipesToRead removeObject:pipe];

			/* No read pipe left, just close all write */
			if ([_pipesToRead count] == 0)
			{
				DESTROY(_pipesToRead);

				en = [_pipesToWrite objectEnumerator];
				while ((pipe = [en nextObject]))
				{
					[[pipe fileHandleForWriting] closeFile];
				}
				[_pipesToWrite removeAllObjects];
			}
		}
		return;
	}

	NSEnumerator *en = [_pipesToWrite objectEnumerator];
	NSPipe *pipeToWrite;
	while ((pipeToWrite = [en nextObject]))
	{
		[[pipeToWrite fileHandleForWriting] writeData:data];

	}


	[handle waitForDataInBackgroundAndNotify];
}

- (void) addPipeToRead: (NSPipe *)pipe
{
	NSFileHandle * handle = [pipe fileHandleForReading];
	[[NSNotificationCenter defaultCenter] addObserver: self
						 selector: @selector(receivedData:)
						     name: NSFileHandleDataAvailableNotification
						   object: handle];
	[handle waitForDataInBackgroundAndNotify];

	[_pipesToRead addObject:pipe];
}

- (void) pipeTeeForWriting: (TMTeePipe *)tee
{
	NSPipe *pipe = [NSPipe pipe];
	[_pipesToWrite addObject:pipe];
	[tee addPipeToRead:pipe];
}

- (void) pipeTeeForReading: (TMTeePipe *)tee
{
	[tee pipeTeeForWriting:self];
}
@end

