
#import "WXApiManager_ios.h"
#import "WXApiHandler_ios.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
//        SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
        //把返回的类型转换成与发送时相对于的返回类型,这里为SendMessageToWXResp
        SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
        WXApiHandler_ios::onShareRespForIOS(sendResp.errCode);
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        ;
        if(authResp.errCode == 0)
            WXApiHandler_ios::onRespForIOS([[authResp code] UTF8String]);
    }else if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        WXApiHandler_ios::onPayRespForIOS(resp.errCode);
        switch (resp.errCode) {
                
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                // NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！"];
                // NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                break;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)onReq:(BaseReq *)req {

}

@end
