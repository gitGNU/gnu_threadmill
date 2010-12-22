#import <AppKit/AppKit.h>

@class TMNode;

@interface TMView : NSView
{
	NSArray *_nodes;
}

- (void) addNode:(TMNode *)aNode;
@end

@interface TMView (Toy)
- (void) addTestNode:(id)sender;
@end
