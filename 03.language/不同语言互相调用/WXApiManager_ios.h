
#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WXApiManager : NSObject<WXApiDelegate>

+ (instancetype)sharedManager;

@end
