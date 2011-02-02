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

#ifndef _TMLib_Included_TMNode_h
#define _TMLib_Included_TMNode_h

#import <Foundation/Foundation.h>

typedef enum _TMDirection
{
	TMBothDirection = 0,
	TMForwardDirection = 1,
	TMBackwardDirection = 2,
} TMDirection;

@interface TMNode : NSObject
{
}

- (NSString *) name;
- (NSArray *) imports;
- (NSArray *) exports;

- (BOOL) setExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode;

- (BOOL) removeExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode;

+ (id) nodeWithImports:(NSArray *)importList
		exports:(NSArray *)exportList;

- (void) run;
@end

@interface TMSimpleNode : TMNode
{
	NSMutableDictionary *_imports;
	NSMutableDictionary *_exports;
}

- (BOOL) createImportWithName:(NSString *)importName;
- (BOOL) createExportWithName:(NSString *)exportName;
- (id) initWithImports:(NSArray *)importList
		exports:(NSArray *)exportList;
@end

#endif
