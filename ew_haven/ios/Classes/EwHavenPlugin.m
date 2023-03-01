#import "EwHavenPlugin.h"
#if __has_include(<ew_haven/ew_haven-Swift.h>)
#import <ew_haven/ew_haven-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ew_haven-Swift.h"
#endif

@implementation EwHavenPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEwHavenPlugin registerWithRegistrar:registrar];
}
@end
