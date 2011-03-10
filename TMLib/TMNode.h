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
+ (id) nodeWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList;

	       /*
+ (void) setDependant: (NSOperation *)operation
	     forNodes: (NSArray *)nodeList
	        queue: (NSOperationQueue *)queue
	        order: (NSDictionary *)opOrder;
		*/

- (NSString *) name;
- (Class) operationClass;

/* array of name strings */
- (NSArray *) allImports;
- (NSArray *) allExports;
- (NSString *) displayNameForImport: (NSString *)import;
- (NSString *) displayNameForExport: (NSString *)export;

/* return series of TMConnecting */
- (NSArray *) setExport: (NSString *)exportName
	      forImport: (NSString *)importName
	         onNode: (TMNode *)aNode;

- (NSArray *) removeExport: (NSString *)exportName
		 forImport: (NSString *)importName
		    onNode: (TMNode *)aNode;

- (NSArray *) setExport: (NSString *)exportName
	      forImport: (NSString *)importName
	         onNode: (TMNode *)aNode
	            try: (BOOL)try;

- (NSArray *) removeExport: (NSString *)exportName
		 forImport: (NSString *)importName
		    onNode: (TMNode *)aNode
		       try: (BOOL)try;

- (void) pushQueue: (NSOperationQueue *)queue
	  forOrder: (NSDictionary *)opOrder;
- (void) finishOrder: (NSDictionary *)opOrder;
/* TODO implement the higher level -pushOrder: which will create
   and maintain a stack of orders (fifo dependency) and finish
   them and use a default queue for the linking group. */
//- (void) pushOrder: (NSDictionary *)opOrder;

@end

@interface TMGenericNode : TMNode
{
	Class _opClass;
	NSMutableDictionary *_imports;
	NSMutableDictionary *_exports;
}

- (void) setOperationClass: (Class)aClass;
- (BOOL) createImport: (NSString *)importName;
- (BOOL) createExport: (NSString *)exportName;
- (id) initWithImports: (NSArray *)importList
	       exports: (NSArray *)exportList;
@end

#endif
