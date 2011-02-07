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

#ifndef _TMLib_Included_TMPort_h
#define _TMLib_Included_TMPort_h

#import <Foundation/Foundation.h>

@class TMAbstractNode;
@class TMPair;

@interface TMPort : NSObject
{
	NSUInteger _pairs_n;
	id *_pairs;
@public
	TMNode *__node;
	NSUInteger _priority;
	BOOL _isPreparing;
}

- (NSString *) name;
@end

#endif
