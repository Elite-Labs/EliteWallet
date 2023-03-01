#import "EwWowneroPlugin.h"
#import <ew_wownero/ew_wownero-Swift.h>

@implementation EwWowneroPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEwWowneroPlugin registerWithRegistrar:registrar];
}
@end
