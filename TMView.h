#import <AppKit/AppKit.h>

@class TMNode;

@interface TMView : NSView
{
	NSArray *_nodes;
}

- (void) addNode:(TMNode *)aNode;
@end
