#import "EwMoneroPlugin.h"
#import <ew_monero/ew_monero-Swift.h>

@implementation EwMoneroPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEwMoneroPlugin registerWithRegistrar:registrar];
}
@end
