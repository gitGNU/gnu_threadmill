#import <AppKit/AppKit.h>

@interface TMPortCell : NSCell
{
	NSColor *_borderColor;
	NSColor *_backgroundColor;
	NSColor *_hilightColor;
	BOOL _drawHilight;
	
//	NSView *_cellContent;
}
- (id) initWithName:(NSString *)aName;
- (void) setHighlight:(BOOL)drawHi;
- (void) setBackgroundColor:(NSColor *)aColor;
- (void) setHighlightColor:(NSColor *)aColor;
- (void) setBorderColor:(NSColor *)aColor;
@end


@interface TMImportCell : TMPortCell
@end

@interface TMExportCell : TMPortCell
@end
