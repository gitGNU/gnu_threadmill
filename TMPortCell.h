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

#import <AppKit/AppKit.h>

typedef struct _TMAxisRange
{
	CGFloat location;
	CGFloat length;
} TMAxisRange;

TMAxisRange TMMakeAxisRange(CGFloat location, CGFloat length);
TMAxisRange TMIntersectionAxisRange(TMAxisRange aRange, TMAxisRange bRange);

@interface TMPortCell : NSCell
{
	NSColor *_borderColor;
	NSColor *_backgroundColor;
	NSColor *_hilightColor;
	BOOL _drawHilight;
	BOOL _handleMode;
	TMAxisRange _range;

	NSMutableArray *_pairCells;
	
//	NSView *_cellContent;
}
- (id) initWithName:(NSString *)aName;
- (void) setHighlight:(BOOL)drawHi;
- (NSColor *) backgroundColor;
- (void) setBackgroundColor:(NSColor *)aColor;
- (void) setHighlightColor:(NSColor *)aColor;
- (void) setBorderColor:(NSColor *)aColor;

- (void) setHandleMode:(BOOL)mode;


- (NSArray *) pairs;
@end


@interface TMImportCell : TMPortCell
@end

@interface TMExportCell : TMPortCell
@end
