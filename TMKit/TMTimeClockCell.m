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

#include "TMTimeClockCell.h"
#include <Foundation/NSAffineTransform.h>
#include <Foundation/NSRunLoop.h>
#include <AppKit/NSGraphics.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/DPSOperators.h>
#include <math.h>

#define TMTIMECLOCKCELL_FACTOR_H 0.3
#define TMTIMECLOCKCELL_FACTOR_M 0.42
#define TMTIMECLOCKCELL_FACTOR_S 0.462
#define TMTIMECLOCKCELL_FACTOR_W 0.04

@implementation TMTimeClockCell
NSDate   *theDistantFuture;
+ (void) initialize
{
  theDistantFuture = [NSDate distantFuture];
}

- (id) init
{
  [self initImageCell:nil];
  _date = [NSDate distantPast];
  RETAIN(_date);
  return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
  [super initWithCoder:coder];
  if ([coder allowsKeyedCoding])
    {
      [self setDate:[coder decodeObjectForKey:@"NSDate"]];
    }
  else
    {
      NSDate *aDate;
      [coder decodeValueOfObjCType:@encode(id) at:&aDate];
      [self setDate:aDate];
    }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
  if ([coder allowsKeyedCoding])
    {
      [coder encodeObject:_date forKey:@"NSDate"];
    }
  else
    {
      [coder encodeObject:_date];
    }
}


- (void) dealloc
{
  RELEASE(_date);
  [super dealloc];
}

- (BOOL) isFlipped
{
  return NO;
}

- (void) setBackgroundColor:(NSColor *)aColor
{
  [self subclassResponsibility: _cmd];
}

- (NSColor *) backgroundColor
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) setColor:(NSColor *)aColor
{
  [self subclassResponsibility: _cmd];
}

- (NSColor *) color
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) setBorderColor:(NSColor *)aColor
{
  [self subclassResponsibility: _cmd];
}

- (NSColor *) borderColor
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) setDate:(NSDate *)date
{
  ASSIGN(_date,date);
}

- (NSDate *) date
{
  return _date;
}

- (void) setFont:(NSFont *)font
{
  [self subclassResponsibility: _cmd];
}

- (NSFont *) font
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) drawInteriorWithFrame: (NSRect)cellFrame inView: (NSView*)controlView
{
  /* this could be replaced with a plain text string */
  [self subclassResponsibility: _cmd];
}

- (BOOL) isOpaque
{
  return YES;
}

- (BOOL) trackMouse:(NSEvent*)theEvent
	     inRect:(NSRect)cellFrame
	     ofView:(NSView*)controlView
       untilMouseUp:(BOOL)flag
{
  /* NYI */
  return NO;
}
@end

@implementation TMTimeAnalogClockCell
+ (BOOL) prefersTrackingUntilMouseUp
{
  return YES;
}

- (id) init
{
  self = [self initImageCell:nil];
  return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
  [super initWithCoder:coder];
  return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
  [super encodeWithCoder:coder];
}

- (NSSize) cellSize
{
  return NSMakeSize(30,30);
}

/*
- (NSRect) trackRect
{
	return NSMakeRect();
}
*/

- (BOOL) trackMouse: (NSEvent*)theEvent
             inRect: (NSRect)cellFrame
             ofView: (NSView*)controlView
       untilMouseUp: (BOOL)flag
{
  unsigned int eventMask = NSLeftMouseDownMask | NSLeftMouseUpMask
    | NSLeftMouseDraggedMask | NSMouseMovedMask;
  NSEventType eventType = [theEvent type];
  NSPoint p,ep;

  cellFrame = [self drawingRectForBounds: cellFrame];

  NSTimeInterval clockTime = [_date timeIntervalSinceReferenceDate] + _offset;
  NSTimeInterval rtime = 0;
  NSTimeInterval rc,ro;
  clockTime = fmod(clockTime, 43200.);
  float hand = clockTime / 21600. * M_PI;

  ep = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];

  /* collapse these transform into manual calculation later */
  NSAffineTransform *btr = [NSAffineTransform transform];
  float scale = MIN(NSWidth(cellFrame), NSHeight(cellFrame));
  [btr scaleXBy:1/scale yBy:1/scale];
  if ([controlView isFlipped])
    {
      [btr rotateByRadians:M_PI];
      hand *= -1;
    }

  float w = TMTIMECLOCKCELL_FACTOR_W;
  if (w * scale < 2.0)
    {
      w = 2.0/scale;
    }


  NSAffineTransform *htr = [btr copy];
  [htr rotateByRadians:hand];
  [htr translateXBy:-NSMidX(cellFrame) yBy:-NSMidY(cellFrame)];
  p = [htr transformPoint:ep];
  RELEASE(htr);

  if (fabs(p.x) < w && p.y < TMTIMECLOCKCELL_FACTOR_H && p.y > 0.)
    {
      rtime = 12 * 3600 / (2 * -M_PI);
      _selectedHand_ = TMTimeAnalogClockHourHand;
    }
  else
    {
      hand *= 12.;
      htr = [btr copy];
      [htr rotateByRadians:hand];
      [htr translateXBy:-NSMidX(cellFrame) yBy:-NSMidY(cellFrame)];
      p = [htr transformPoint:ep];
      RELEASE(htr);
      if (fabs(p.x) < w && p.y < TMTIMECLOCKCELL_FACTOR_M && p.y > 0.)
	{
	  rtime = 60 * 60 / (2 * -M_PI);
	  _selectedHand_ = TMTimeAnalogClockMinuteHand;
	}
      else
	{
	  hand *= 60.;
	  htr = [btr copy];
	  [htr rotateByRadians:hand];
	  [htr translateXBy:-NSMidX(cellFrame) yBy:-NSMidY(cellFrame)];
	  p = [htr transformPoint:ep];
	  RELEASE(htr);

	  if (fabs(p.x) < w && p.y < TMTIMECLOCKCELL_FACTOR_S && p.y > 0.)
	    {
	      rtime = 60 / (2 * -M_PI);
	      _selectedHand_ = TMTimeAnalogClockSecondHand;
	    }
	}
    }

  if ([controlView isFlipped])
    {
      rtime *= -1;
    }

  ep.y -= NSMidY(cellFrame);
  ep.x -= NSMidX(cellFrame);

  ro = atan2(ep.y,ep.x);

  while (eventType != NSLeftMouseUp)
    {
      p = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];

      p.y -= NSMidY(cellFrame);
      p.x -= NSMidX(cellFrame);

      rc = atan2(p.y,p.x);
      if (!isnan(rc))
	{
	  rc -= ro;
	  ro += rc;

	  if (rc < 0)
	    {
	      rc += 2 * M_PI;
	    }

	  if (rc > M_PI)
	    {
	      rc -= 2 * M_PI;
	    }

	  _offset += (rc * rtime);

	  [controlView setNeedsDisplayInRect:cellFrame];
	}


      theEvent = [NSApp nextEventMatchingMask: eventMask
				    untilDate: theDistantFuture
				       inMode: NSEventTrackingRunLoopMode
				      dequeue: YES];
      eventType = [theEvent type];
    }

  _selectedHand_ = TMTimeAnalogClockNoHand;
  return YES;
}

- (NSDate *) date
{
  return [_date addTimeInterval:_offset];
}

- (void) setDate:(NSDate *) newDate
{
  _offset = 0.;
  [super setDate:newDate];
}


/*
- (void) setTickIncrementInterval:(NSTimeInterval)anInterval
{
}

- (NSTimeInterval) tickIncrementInterval
{
}

- (id) addTimeInterval:(NSTimeInterval)seconds
{

}
*/


- (void) drawInteriorWithFrame:(NSRect)cellFrame
			inView:(NSView *)controlView
{
  int imark; float rmark;

  NSGraphicsContext *ctxt=GSCurrentContext();
  cellFrame = [self drawingRectForBounds: cellFrame];
  float scale = MIN(NSWidth(cellFrame), NSHeight(cellFrame));

  [[NSColor windowBackgroundColor] set];
  NSRectFill(cellFrame);

  DPSgsave(ctxt);
  //DPSinitclip(ctxt);

  DPStranslate(ctxt, NSMidX(cellFrame), NSMidY(cellFrame));
  if ([controlView isFlipped])
    {
      DPSrotate(ctxt, 180);
    }
  DPSscale(ctxt, scale, scale);

  NSTimeInterval hand;
  NSTimeInterval clockTime;

  clockTime = [_date timeIntervalSinceReferenceDate] + _offset;

  float x,y;

  [[NSColor whiteColor] set];
  DPSmoveto(ctxt, 0.5, 0.);
  DPSarc(ctxt, 0., 0., 0.5, 0., 360.);
  DPSfill(ctxt);

  hand = clockTime / 21600 * M_PI;
  if ([controlView isFlipped])
    {
      hand *= -1;
    }

  [[NSColor blackColor] set];
  DPSsetlinewidth(ctxt, TMTIMECLOCKCELL_FACTOR_W/2);
  for (imark = 0, rmark = 0.; imark < 12; imark++, rmark += M_PI/6.)
    {
      x = sin(rmark);
      y = cos(rmark);
      DPSmoveto(ctxt, x * 0.49, y * 0.49);
      DPSlineto(ctxt, x * 0.43, y * 0.43);

      /*
	 for (jmark = 0, rmark+= M_PI/30.; jmark < 4; jmark++, rmark+= M_PI/30.)
	 {
	 x = sin(rmark);
	 y = cos(rmark);
	 DPSmoveto(ctxt, x * 0.49, y * 0.49);
	 DPSlineto(ctxt, x * 0.47, y * 0.47);
	 }
	 */
    }
  DPSstroke(ctxt);

  x = sin(hand) * TMTIMECLOCKCELL_FACTOR_H;
  y = cos(hand) * TMTIMECLOCKCELL_FACTOR_H;

  if (_selectedHand_ == TMTimeAnalogClockHourHand)
    {
      [[NSColor blueColor] set];
    }
  else
    {
      [[NSColor blackColor] set];
    }
  DPSsetlinewidth(ctxt, TMTIMECLOCKCELL_FACTOR_W * 2);
  DPSmoveto(ctxt, x, y);
  DPSrlineto(ctxt, x * -1.3, y * -1.3);
  DPSstroke(ctxt);

  hand *= 12;
  x = sin(hand) * TMTIMECLOCKCELL_FACTOR_M;
  y = cos(hand) * TMTIMECLOCKCELL_FACTOR_M;

  if (_selectedHand_ == TMTimeAnalogClockMinuteHand)
    {
      [[NSColor blueColor] set];
    }
  else
    {
      [[NSColor blackColor] set];
    }
  DPSsetlinewidth(ctxt, TMTIMECLOCKCELL_FACTOR_W * 1.2);
  DPSmoveto(ctxt, x, y);
  DPSrlineto(ctxt, x * -1.4, y * -1.4);
  DPSstroke(ctxt);

  hand *= 60;
  x = sin(hand) * TMTIMECLOCKCELL_FACTOR_S;
  y = cos(hand) * TMTIMECLOCKCELL_FACTOR_S;


  if (_selectedHand_ > TMTimeAnalogClockSecondHand)
    {
      goto restore;
    }
  else if (_selectedHand_ == TMTimeAnalogClockSecondHand)
    {
      [[NSColor blueColor] set];
    }
  else
    {
      [[NSColor redColor] set];
    }

  DPSsetlinewidth(ctxt, TMTIMECLOCKCELL_FACTOR_W * 0.4);
  DPSmoveto(ctxt, x, y);
  DPSrlineto(ctxt, x * -1.4, y * -1.4);
  DPSstroke(ctxt);

restore:

  DPSgrestore(ctxt);
}


- (BOOL) isOpaque
{
  return NO;
}

@end

// vim: filetype=objc:cinoptions={.5s,\:.5s,+.5s,t0,g0,^-2,e-2,n-2,p2s,(0,=.5s:formatoptions=croql:cindent:shiftwidth=4:tabstop=8:
