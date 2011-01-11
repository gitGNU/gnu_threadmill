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

#include "TMTimeControl.h"
#include "TMTimeClockCell.h"

#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSDate.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSActionCell.h>


@implementation TMTimeControl

static Class __tm_clock_cell_class;

+ (void) initialize
{
	if (self == [TMTimeControl class])
	{
		[self setCellClass: [TMTimeAnalogClockCell class]];
	}
}

+ (void) setCellClass:(Class)aClass
{
	__tm_clock_cell_class = aClass;
}


+ (Class) cellClass
{
	return __tm_clock_cell_class;
}

- (id) initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];

	[_cell setDate:[NSDate date]];

	return self;
}

/* appearance */

- (void) setBackgroundColor:(NSColor *)aColor
{
	[_cell setBackgroundColor:aColor];
}

- (NSColor *) backgroundColor

{
	return [_cell backgroundColor];
}

- (void) setColor:(NSColor *)aColor
{
	[_cell setColor:aColor];
}

- (NSColor *) color
{
	return [_cell color];
}

- (void) setBorderColor:(NSColor *)aColor
{
	[_cell setBorderColor:aColor];
}

- (NSColor *) borderColor
{
	return [_cell borderColor];
}

- (void) setImage:(NSImage *)backgroundImage
{
	[_cell setImage:backgroundImage];
}

- (NSImage *) image
{
	return [_cell image];
}

- (void) setFont:(NSFont *)font
{
	[_cell setFont:font];
}

- (NSFont *) font
{
	return [_cell font];
}

- (void) setDate:(NSDate *)date
{
	[_cell setDate:date];
	[self setNeedsDisplay:YES];
}

- (NSDate *) date
{
	return [_cell date];
}

/*
- (void) mouseDown:(NSEvent *)theEvent
{
	if ([_cell isEnabled])
	{
	}
}
*/

- (void) awakeFromNib
{
}

@end

// vim: filetype=objc:cinoptions={.5s,\:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s:formatoptions=croql:cindent:shiftwidth=4:tabstop=8:
