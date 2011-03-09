/*
 *   Threadmill - GNUstep multi-purpose node graph application architecture.
 *   Copyright © 2011 Banlu Kemiyatorn <object@gmail.com>                                        )
 *                                                                                              /
 *   This program is free software; you can redistribute it and/or modify   _   ____           ((
 *   it under the terms of the GNU General Public License as published by  / \ / __ \           ))
 *   the Free Software Foundation; either version 3 of the License, or    _\__y,'  ) )    __,--'/
 *   (at your option) any later version.                              __,'       _- /_,--'     Y
 *                                                                   (      ^     .-'           \
 *   This program is distributed in the hope that it will be useful,  \____      ,               `.__
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of      \_)_ ,-'             __,..,_)
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           7           __,.'
 *   GNU General Public License for more details.                          .',-y   __,.-'
 *                                                                        (_/ .',''
 *   You should have received a copy of the GNU General Public License       (_/
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301
 */

#import <TMKit/TMView.h>
#import <TMLib/TMTaskNode.h>

@class TMTimeControl;

@interface MyNode : TMGenericNode
{
}
@end

@implementation MyNode
- (NSString *) name
{
	return @"My node";
}

- (void) setDate:(id)sender
{
	NSLog(@"setDate");
}
@end

@interface Threadmill : NSApplication
{
	TMView *_mainView;
	NSMutableArray *_buttonList;
}
- (void) addTestNode:(id)sender;
@end

#define RR (0.3 + 0.7 * (float)rand() / RAND_MAX)

@implementation Threadmill

- (void) addTestNode:(id)sender
{
	if (_buttonList == nil) _buttonList = [NSMutableArray new];

	TMNode *newNode;
	if ([sender tag] == 1)
	{
		newNode  = [MyNode nodeWithImports:[NSArray arrayWithObjects:
					@"test import 1",
					@"TEST \n   import 2",
					@"test import 3",
					nil]
				exports:[NSArray arrayWithObjects:
					@"test export 1",
					@"test export 2",
					@"test \noh yeh\n my export 3",
					nil]];
	}
	else if ([sender tag] == 2)
	{
		newNode  = [TMNode nodeWithImports:[NSArray arrayWithObjects:
					@"test import 1",
					@"TEST \n   import 2",
					@"test import 3",
					nil]
				exports:[NSArray arrayWithObjects:
					@"test export 1",
					@"test export 2",
					@"test \noh yeh\n my export 3",
					nil]];
	}
	else if ([sender tag] == 3)
	{
		newNode  = [TMNode nodeWithImports:[NSArray arrayWithObjects:
					@"test import 1",
					@"TEST \n   import 2",
					@"test import 3",
					nil]
				exports:[NSArray arrayWithObjects:
					@"test export 1",
					@"test export 2",
					@"test \noh yeh\n my export 3",
					nil]];
	}
	else if ([sender tag] == 4)
	{
		newNode  = [TMTaskNode nodeWithLaunchPath:@"something" arguments:nil];
	}

	TMNodeView *newNodeView = [_mainView addNode:newNode];

/*
	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.36*RR green:0.54*RR blue:0.66*RR alpha:1.0]
		forExport:@"test export 1"];
	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.55*RR green:0.71*RR blue:0.00*RR alpha:1.0]
		forExport:@"test \noh yeh\n my export 3"];

	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.82*RR green:0.10*RR blue:0.26*RR alpha:1.0]
		forExport:@"test export 2"];

	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.71*RR green:0.26*RR blue:0.66*RR alpha:1.0]
		forImport:@"test import 1"];
	[newNodeView setBackgroundColor:[NSColor lightGrayColor]
		forImport:@"TEST \n   import 2"];
	[newNodeView setBackgroundColor:[NSColor colorWithDeviceRed:0.36*RR green:0.26*RR blue:0.71*RR alpha:1.0]
		forImport:@"test import 3"];
*/

	static CGFloat size = 60;
	if ([sender tag] == 1)
	{
		size *= 1.5;
		TMTimeControl *control = AUTORELEASE([[TMTimeControl alloc] initWithFrame:NSMakeRect(0,0,size,size)]);
		[control setTarget:newNode];
		[control setAction:@selector(setDate:)];
		[newNodeView setContentView:control];
	}
	else if ([sender tag] == 2)
	{
		size /= 1.5;
		NSImageView *imageView = AUTORELEASE([[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, size, size)]);
		[imageView setImage:[NSImage imageNamed:@"Threadmill-Logo.tiff"]];
		[imageView setImageScaling:NSScaleToFit];
		[newNodeView setContentView:imageView];
	}
	else if ([sender tag] == 3)
	{
		NSButton *button = AUTORELEASE([[NSButton alloc] initWithFrame:NSMakeRect(0,0,size * 2,size)]);
		[button setImage:[NSImage imageNamed:@"Threadmill.tiff"]];
		[button setTarget:newNodeView];
		[button setAction:@selector(queue:)];

		[newNodeView setContentView:button];

		[_buttonList addObject:newNodeView];
	}
	else if ([sender tag] == 4)
	{
		NSButton *button = AUTORELEASE([[NSButton alloc] initWithFrame:NSMakeRect(0,0,size * 2,size)]);
		[button setImage:[NSImage imageNamed:@"Threadmill.tiff"]];
		[button setTarget:newNodeView];
		[button setAction:@selector(queue:)];

		[newNodeView setContentView:button];

		[_buttonList addObject:newNodeView];
	}
	if (size < 60) size = 60;
}

@end
