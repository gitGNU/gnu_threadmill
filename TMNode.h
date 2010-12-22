#import <Foundation/Foundation.h>

@class TMPort;

@interface TMNode : NSObject
{
	NSDictionary *_imports;
	NSDictionary *_exports;
}

- (NSString *) name;
- (NSArray *) importNames;
- (NSArray *) exportNames;
- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName;
- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName;

@end
