#import "TMPortCell.h"

@implementation TMPortCell
- (id) initWithName:(NSString *)aName
{
	return [self initTextCell:aName];
}
@end

@implementation TMImportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	return self;
}
@end

@implementation TMExportCell
- (id) initWithName:(NSString *)aName
{
	[super initWithName:aName];
	return self;
}
@end
