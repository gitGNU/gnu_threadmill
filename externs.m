#import <Foundation/NSString.h>
#import <AppKit/NSImage.h>
#import "TMGraphics.h"

NSString * TMPasteboardTypeImportLink = @"TMPasteboardTypeImportLink";
NSString * TMPasteboardTypeExportLink = @"TMPasteboardTypeExportLink";

void TMFillImageAtPointInRect(NSImage *image, NSPoint p, NSRect r)
{
	NSRect imRect;
	imRect.origin = NSZeroPoint;
	imRect.size = [image size];

	NSPoint dp;

	p.x = NSMinX(r) - fmod(NSMinX(r) - p.x, NSWidth(imRect));
	p.y = NSMinY(r) - fmod(NSMinY(r) - p.y, NSHeight(imRect));
	
	[[NSColor redColor] set];
	int blocks = 0;
	for (dp.y = p.y; dp.y < NSMaxY(r); dp.y += NSHeight(imRect))
	for (dp.x = p.x; dp.x < NSMaxX(r); dp.x += NSWidth(imRect))
	{
		NSRect drawRect = [


		[image compositeToPoint:dp fromRect:imRect operation:NSCompositeSourceOver];
	}
}

TMAxisRange TMMakeAxisRange(CGFloat location, CGFloat length)
{
	TMAxisRange range;

	if (length < 0)
	{
		range.location = location + length;
		range.length = -length;
	}
	else
	{
		range.location = location;
		range.length = length;
	}

	return range;
}

TMAxisRange TMIntersectionAxisRange(TMAxisRange aRange, TMAxisRange bRange)
{
	
	CGFloat maxA = aRange.location + aRange.length;
	CGFloat maxB = bRange.location + bRange.length;

	if (maxA < bRange.location || maxB < aRange.location)
		return TMMakeAxisRange(0, 0);

	CGFloat maxLoc = MAX(aRange.location, bRange.location);
	return TMMakeAxisRange(maxLoc, MIN(maxA, maxB) - maxLoc);
}


