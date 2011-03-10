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

        /* FIXME the order should be associated with something like the NSEvent that caused it */
	NSArray *pathsA = [NSArray arrayWithObject:@"/"];
	NSArray *pathsB = [NSArray arrayWithObject:@"/home"];


	NSArray *args = [[NSProcessInfo processInfo] arguments];
	[[[NSProcessInfo processInfo] debugSet] addObject:@"TMTaskNode"];

	if ([args count] == 3)
	{
		pathsA = [NSArray arrayWithObject:[args objectAtIndex:1]];
		pathsB = [NSArray arrayWithObject:[args objectAtIndex:2]];
	}

	TMTaskNode * listA = [TMTaskNode nodeWithLaunchPath:@"/bin/ls" arguments:pathsA];
	TMTaskNode * listB = [TMTaskNode nodeWithLaunchPath:@"/bin/ls" arguments:pathsB];
	TMTaskNode * sort = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/sort" arguments:[NSArray arrayWithObject:@"-r"]];
	TMTaskNode * tee = [TMTaskNode nodeWithLaunchPath:@"/usr/bin/tee" arguments:[NSArray arrayWithObjects:@"-a",@"logfile.txt",nil]];

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


	/*
	TMTaskNode * catA = [TMTaskNode nodeWithLaunchPath:@"/bin/cat" arguments:[NSArray arrayWithObject:[args objectAtIndex:1]]];
	TMTaskNode * catB = [TMTaskNode nodeWithLaunchPath:@"/bin/cat" arguments:[NSArray arrayWithObject:[args objectAtIndex:2]]];
	TMTaskNode * convertAppend;
	TMTaskNode * display;
	*/

	[NSTimer scheduledTimerWithTimeInterval:2000.
		target:nil
		selector:NULL
		userInfo:nil
		repeats:NO];

	[[NSRunLoop currentRunLoop] run];
	RELEASE(p);
	return 0;
}
