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

#ifndef _TMLib_Included_TMConnector_h
#define _TMLib_Included_TMConnector_h

#import <Foundation/Foundation.h>
#import <TMLib/TMNodeInternal.h>

@class TMNode;
@class TMPair;

@interface TMConnector : NSObject
{
//	NSUInteger _current_pair;
	NSUInteger _pairs_n;
	TMConnector **_pairs;

	TMNode *__node;
	NSString *__port;
}

- (TMNode *) node;
- (NSString *) port;
- (NSArray *) allPairs;

+ (id) connectorForNode: (TMNode *)aNode
		   port: (NSString *)name;

- (BOOL) connect:(TMConnector *)aPair;
- (void) disconnect:(TMConnector *)aPair;

- (void) setDependant: (NSOperation *)dependant
	     forQueue: (NSOperationQueue *)queue
		order: (NSDictionary *)opOrder;
- (void) finishOrder: (NSDictionary *)opOrder;
- (void) pushQueue: (NSOperationQueue *) queue
	  forOrder: (NSDictionary *)opOrder;
@end

#endif
