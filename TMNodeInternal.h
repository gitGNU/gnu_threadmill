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

#import "TMNode.h"
#import "TMPortInternal.h"

@interface TMNode (Internal)

/*
- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName;
- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName;
*/

- (BOOL) setExport:(TMPort *)aPort
	forImportName:(NSString *)aName;
//- (TMPortDirection) directionOfPort:(TMPort *)aPort;
@end
