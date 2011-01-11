#import <Foundation/NSString.h>
#import <AppKit/NSImage.h>
#import "TMGraphics.h"

NSString * TMPasteboardTypeImportLink = @"TMPasteboardTypeImportLink";
NSString * TMPasteboardTypeExportLink = @"TMPasteboardTypeExportLink";

void TMFillPatternInRect(NSImage *image, NSRect r)
{
	NSSize imSize = [image size];

	NSPoint p = NSZeroPoint;
	NSPoint dp;

	r = NSIntegralRect(r);

	p.x = imSize.width * floor(NSMinX(r) / imSize.width);
	p.y = imSize.height * floor(NSMinY(r) / imSize.height);
	
	for (dp.y = p.y; dp.y < NSMaxY(r); dp.y += imSize.height)
	for (dp.x = p.x; dp.x < NSMaxX(r); dp.x += imSize.width)
	{
		NSRect drawRect;

		drawRect.origin = dp;
		drawRect.size = imSize;

		drawRect = NSIntersectionRect(r, drawRect);

		[image compositeToPoint:drawRect.origin
			fromRect:NSOffsetRect(drawRect, -dp.x, -dp.y)
			operation:NSCompositeSourceOver];
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


