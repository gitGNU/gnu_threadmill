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

@implementation TMTeePipe

+ (id) tee
{
	return AUTORELEASE([[self alloc] init]);
}

- (id) init
{
	[super init];
	_readPipes = [[NSMutableArray alloc] init];
	_writePipes = [[NSMutableArray alloc] init];
	return self;
}

- (void) dealloc
{
	DESTROY(_readPipes);
	DESTROY(_writePipes);
	[super dealloc];
}

- (NSFileHandle *) fileHandleForReading
{
	NSPipe *newPipe = [NSPipe pipe];
	[_writePipes addObject:newPipe];
	return [newPipe fileHandleForReading];
}

- (void) receivedData: (NSNotification *)not
{
	NSFileHandle * handle = [not object];
	NSData *data = [handle availableData];

	if ([data length] == 0) return;

	NSEnumerator *en = [_writePipes objectEnumerator];
	NSPipe *writePipe;
	while ((writePipe = [en nextObject]))
	{
		[[writePipe fileHandleForWriting] writeData:data];
	}

	[handle waitForDataInBackgroundAndNotify];
}

- (NSFileHandle *) fileHandleForWriting
{
	NSPipe *newPipe = [NSPipe pipe];
	NSFileHandle * handle = [newPipe fileHandleForReading];
	[[NSNotificationCenter defaultCenter] addObserver: self
						 selector: @selector(receivedData:)
						     name: NSFileHandleDataAvailableNotification
						   object: handle];
	[handle waitForDataInBackgroundAndNotify];

	[_readPipes addObject:newPipe];
	return [newPipe fileHandleForWriting];
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
@end

