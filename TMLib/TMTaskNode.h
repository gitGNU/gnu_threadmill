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

#ifndef _TMLib_Included_TMTaskNode_h
#define _TMLib_Included_TMTaskNode_h

#import <Foundation/Foundation.h>
#import <TMLib/TMNodeInternal.h>

extern NSString * const TMStandardInputPort;
extern NSString * const TMStandardOutputPort;
extern NSString * const TMStandardErrorPort;

@interface TMTaskNode : TMNode
{
	NSString *_launchPath;
	NSArray *_arguments;

	TMConnector *_inCon;
	TMConnector *_outCon;
	TMConnector *_errCon;
}

- (id) initWithLaunchPath: (NSString *)launchPath
		arguments: (NSArray *)arguments;
- (NSString *) launchPath;
- (NSArray *) arguments;
@end

#endif
