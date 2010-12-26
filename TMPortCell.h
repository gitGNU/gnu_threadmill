#import <AppKit/AppKit.h>

@interface TMPortCell : NSActionCell
{
	NSView *_cellContent;
}
- (id) initWithName:(NSString *)aName;
@end


@interface TMImportCell : TMPortCell
@end

@interface TMExportCell : TMPortCell
@end
