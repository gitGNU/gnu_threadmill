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

#ifndef _TMKit_Included_TMTimeControl_h
#define _TMKit_Included_TMTimeControl_h

#include <AppKit/NSControl.h>

@class NSColor;

@interface TMTimeControl : NSControl

/* appearance */

- (void) setBackgroundColor:(NSColor *)aColor;
- (NSColor *) backgroundColor;
- (void) setColor:(NSColor *)aColor;
- (NSColor *) color;
- (void) setBorderColor:(NSColor *)aColor;
- (NSColor *) borderColor;
- (void) setImage:(NSImage *)backgroundImage;
- (NSImage *) image;
- (void) setFont:(NSFont *)font;
- (NSFont *) font;


/* date & time */

- (void) setDate:(NSDate *)aDate;
- (NSDate *) date;



@end

#endif
