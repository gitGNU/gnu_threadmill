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

#import <Foundation/Foundation.h>

@interface TMNode : NSObject
{
}

- (NSString *) name;
- (NSArray *) importList;
- (NSArray *) exportList;

- (BOOL) setExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode;

- (BOOL) removeExport:(NSString *)exportName
		forImport:(NSString *)importName
		onNode:(TMNode *)aNode;

@end

@interface TMSimpleNode : TMNode
{
	NSMutableDictionary *_imports;
	NSMutableDictionary *_exports;
}

- (BOOL) createImportWithName:(NSString *)importName;
- (BOOL) createExportWithName:(NSString *)exportName;
@end
