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

/* Connecting objects are used to determine the result of connecting process,
   eg. if the setting did remove existing connections and also help the UI to
   display the result of connection before the actual connection (ie. using try: flag).
*/
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

@interface TMNode : NSObject
{
	NSMutableSet *_preps;
	NSMutableDictionary *_orders;
}

- (NSString *) name;
- (Class) operationClass;

/* array of name strings */
- (NSArray *) allImports;
- (NSArray *) allExports;

/* return series of TMConnecting */
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
	        queue: (NSOperationQueue *)queue
	        order: (NSDictionary *)opOrder;
@end

@interface TMGenericNode : TMNode
{
	Class _opClass;
	NSMutableDictionary *_imports;
	NSMutableDictionary *_exports;
}

- (void) setOperationClass: (Class)aClass;
- (BOOL) createImportWithName: (NSString *)importName;
- (BOOL) createExportWithName: (NSString *)exportName;
- (id) initWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList;
@end

#endif
