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

#ifndef _TMKit_Included_TMNodeView_h
#define _TMKit_Included_TMNodeView_h

#import <AppKit/AppKit.h>
#import <Threadmill/TMPortCell.h>

@class TMNode;
@class TMView;
@class TMPort;

@interface TMNodeView : NSView
{
	TMNode *_node;

	id _titleCell;
	id _contentButtonCell;
	NSMutableArray *_portCells;

	CGFloat _areaWidth;
	CGFloat _titleHeight;
	CGFloat _portHeight;

	id __contentView;
	id __portInLight;
	id __portDragOut;
	NSUInteger __hitSearchIndex;

	NSColor *_borderColor;
	BOOL _drawHilight;

}

- (id) initWithNode:(TMNode *)aNode;
- (TMNode *) node;
- (void) setContentView:(NSView *)aView;
- (NSView *) contentView;
- (void) toggleContent:(id)sender;

//FIXME 
- (void) drawDropShadow;

/*
- (NSSet *) allImports;
- (NSSet *) allExports;
- (NSRect) frameForPortCellOfClass:(Class)class
	withName:(NSString *)aName;
	*/
- (NSArray *) portCells;
- (TMPortCell *) portCellAtPoint:(NSPoint)p;
- (NSRect) convertPortCellFrame:(TMPortCell *)aCell
			toView:(NSView *)aView;
/* FIXME */
- (CGFloat) connectionHeightForExportCell:(TMExportCell *)exportCell
			toImportCell:(TMImportCell *)importCell;

- (void) setBackgroundColor:(NSColor *)aColor
	forImport:(NSString *)importName;
- (void) setBackgroundColor:(NSColor *)aColor
	forExport:(NSString *)exportName;
@end

#endif
