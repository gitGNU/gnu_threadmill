#import <Foundation/Foundation.h>

@class TMPort;

@interface TMNode : NSObject
{
	NSDictionary *_imports;
	NSDictionary *_exports;
}

- (void) setImport:(TMPort *)aPort
	   forName:(NSString *)aName;
- (void) setExport:(TMPort *)aPort
	   forName:(NSString *)aName;

@end
