/*
	do What The Fuck you want to Public License

	Version 1.0, March 2010
	Copyright (C) 2010 Banlu Kemiyatorn.
	136 Nives 7 Jangwattana 14 Laksi Bangkok
	Everyone is permitted to copy and distribute verbatim copies
	of this license document, but changing it is not allowed.

	Ok, the purpose of this license is simple
	and you just

	DO WHAT THE FUCK YOU WANT TO.
*/

#import <Foundation/Foundation.h>
#import <TMLib/TMTaskNode.h>

int main(int argc, char *argv[])
{

	CREATE_AUTORELEASE_POOL(p);
	NSOperationQueue * opQueue = [NSOperationQueue mainQueue];

	NSArray *pathsA = [NSArray arrayWithObject:@"/"];
	NSArray *pathsB = [NSArray arrayWithObject:@"/home"];


	NSArray *args = [[NSProcessInfo processInfo] arguments];
//	[[[NSProcessInfo processInfo] debugSet] addObject:@"TMTaskNode"];
//	[[[NSProcessInfo processInfo] debugSet] addObject:@"TMTeePipe"];
//	[[[NSProcessInfo processInfo] debugSet] addObject:@"TMTaskOperation"];

	if ([args count] == 3)
	{
		pathsA = [NSArray arrayWithObject:[args objectAtIndex:1]];
		pathsB = [NSArray arrayWithObject:[args objectAtIndex:2]];
	}

	TMTaskNode *listA = [TMTaskNode nodeWithLaunchPath:@"/bin/ls" arguments:pathsA];
	TMTaskNode *tee = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/tee" arguments:[NSArray arrayWithObjects:@"-a",@"logfile.txt",nil]];
	TMTaskNode *listB = [TMTaskNode nodeWithLaunchPath:@"/bin/ls" arguments:pathsB];
	TMTaskNode *sort = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/sort" arguments:[NSArray arrayWithObject:@"-r"]];

	/*
	   (listA:ls /)-----.
	                     \
	                      >--->(sort:sort -r)--->(tee:tee -a logfile.txt)
	                     /
	   (listB:ls /home)-'
	 */

	/* ports are file descriptors, eg. @"1" means stdout */
	[listA setExport:@"1" forImport:@"0" onNode:sort];
	[listB setExport:@"1" forImport:@"0" onNode:sort];
	[sort setExport:@"1" forImport:@"0" onNode:tee];

	/* execute the graph */

	[listA pushQueue:opQueue forOrder:nil];
	[listA finishOrder:nil];

	/* FIXME Don't do this, as this will block notification that task operations need to be set finished */
	//[opQueue waitUntilAllOperationsAreFinished];


/*
	TMTaskNode *catA = [TMTaskNode nodeWithLaunchPath:@"/bin/cat" arguments:[NSArray arrayWithObject:@"TMKit/Plug.tiff"]];
	TMTaskNode *catB = [TMTaskNode nodeWithLaunchPath:@"/bin/cat" arguments:[NSArray arrayWithObject:@"TMKit/FiberPattern.tiff"]];
	TMTaskNode *convertAppend = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/convert" arguments:[NSArray arrayWithObjects:@"fd:0",@"fd:1",@"-append",nil]];
	TMTaskNode *display = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/display" arguments:[NSArray arrayWithObjects:@"fd:0",nil]];
*/

	[NSTimer scheduledTimerWithTimeInterval:5.
		target:nil
		selector:NULL
		userInfo:nil
		repeats:NO];

	[[NSRunLoop currentRunLoop] run];
	RELEASE(p);

	return 0;
}
