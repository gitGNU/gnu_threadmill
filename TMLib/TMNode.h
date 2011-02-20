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

@class NSOperation;

typedef enum _TMConnectingType
{
	TMConnectingTypeSetExport,
	TMConnectingTypeRemoveExport,
} TMConnectingType;

/* This is mainly used for "try" as it helps querying
   the set result before the actually setting, this help
   the UI to display the result before setting */

@class TMNode;

@interface TMConnecting : NSObject
{
	@public
	TMNode *exporter;
	NSString *export;
	TMConnectingType type;
	TMNode *importer;
	NSString *import;
}
+ (id) connectingWithExporter: (TMNode *)exporter
		       export: (NSString *)export
		     importer: (TMNode *)importer
		       import: (NSString *)import
		         type: (TMConnectingType)type;
@end

@protocol TMNodeDelegate
@end

@interface TMNode : NSObject
{
	NSMutableDictionary * _opInfo;
}

- (NSString *) name;

/* array of name strings */
- (NSArray *) allImports;
- (NSArray *) allExports;

- (void) setDelegate;
- (id <TMNodeDelegate>) delegate;

- (NSArray *) setExport: (NSString *)exportName
	      forImport: (NSString *)importName
	         onNode: (TMNode *)aNode
	            try: (BOOL)try;

- (NSArray *) removeExport: (NSString *)exportName
		 forImport: (NSString *)importName
		    onNode: (TMNode *)aNode
		       try: (BOOL)try;

+ (id) nodeWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList;

+ (void) setDependant: (NSOperation *)operation
	     forNodes: (NSArray *)nodeList
	         info: (NSDictionary *)operationInfo;
@end

@interface TMSimpleNode : TMNode
{
	NSMutableDictionary *_imports;
	NSMutableDictionary *_exports;
}

- (BOOL) createImportWithName: (NSString *)importName;
- (BOOL) createExportWithName: (NSString *)exportName;
- (id) initWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList;
@end

#endif
