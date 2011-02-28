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
#import "TMOperation.h"
@implementation TMOperation
+ (id) operationForOrder: (NSDictionary *)order
{
	TMOperation *op = [[self alloc] initWithOrder:order];
	[op autorelease];
	return op;
}

- (id) initWithOrder: (NSDictionary *)order
{
	[self init];
	[self assignOrder:order];
	return self;
}

- (void) assignOrder: (NSDictionary *)order
{
	__order = order;
}

@end

