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

#ifndef _TMKit_Included_TMPortCellInternal_h
#define _TMKit_Included_TMPortCellInternal_h

#import <Threadmill/TMPortCell.h>

@interface TMPortCell (Internal)
- (void) addConnection:(TMPortCell *)aPortCell;
- (void) deleteConnection:(TMPortCell *)aPortCell;
- (TMAxisRange) range;
- (void) setRange:(TMAxisRange)aRange;
@end

extern NSString * TMPasteboardTypeImportLink;
extern NSString * TMPasteboardTypeExportLink;

#endif
