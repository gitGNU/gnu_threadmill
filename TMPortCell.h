#import <AppKit/AppKit.h>

@interface TMPortCell : NSButtonCell
{
	NSView *_cellContent;
}
- (id) initWithName:(NSString *)aName;
@end


@interface TMImportCell : TMPortCell
@end

@interface TMExportCell : TMPortCell
@end
