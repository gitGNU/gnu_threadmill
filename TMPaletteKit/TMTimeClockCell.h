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

/* TODO : cache panel buffer in factory class's hash (NSStringFromRect) */

#ifndef _TMKit_Included_TMTimeClockCell_h
#define _TMKit_Included_TMTimeClockCell_h

#include <AppKit/NSActionCell.h>

typedef enum
{
  TMTimeAnalogClock = 0,
  TMTimeDigitalClock = 1
} TMTimeClockType;

typedef enum
{
  TMTimeAnalogClockNoHand = 0,
  TMTimeAnalogClockSecondHand = 1 << 0,
  TMTimeAnalogClockMinuteHand = 1 << 1,
  TMTimeAnalogClockHourHand = 1 << 2,
} TMTimeAnalogClockHand;

@interface TMTimeAnalogClockCellStyle : NSObject <NSCoding>
{
}
@end

@interface TMTimeClockCell : NSActionCell <NSCoding>
{
	NSDate *_date;
}

- (void) setBackgroundColor:(NSColor *)aColor;
- (NSColor *) backgroundColor;
- (void) setColor:(NSColor *)aColor;
- (NSColor *) color;
- (void) setBorderColor:(NSColor *)aColor;
- (NSColor *) borderColor;
- (void) setDate:(NSDate *)date;
- (NSDate *) date;
- (void) setFont:(NSFont *)font;
- (NSFont *) font;
@end

@interface TMTimeAnalogClockCell : TMTimeClockCell <NSCoding>
{
	TMTimeAnalogClockCellStyle *_style;
	NSTimeInterval _offset;
	TMTimeAnalogClockHand _selectedHand_;
}

+ (BOOL) prefersTrackingUntilMouseUp;

// replace with initWithClockType: which return the actual kind of cell.
/*
- (void) setClockType:(TMTimeClockType)clockType;
- (TMClockType) clockType;
*/

/*
- (void) setTickIncrementInterval:(NSTimeInterval)anInterval;
- (NSTimeInterval) tickIncrementInterval;
*/
@end


#endif

