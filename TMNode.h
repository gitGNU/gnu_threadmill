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
	NSDictionary *_imports;
	NSDictionary *_exports;
}

- (NSString *) name;
- (NSArray *) importNames;
- (NSArray *) exportNames;
- (void) setImport:(TMNode *)aNode
	forPortName:(NSString *)aName;
- (void) setExport:(TMNode *)aNode
	forPortName:(NSString *)aName;

@end
