
#include "WXApiHandler_ios.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "GameUUID.h"
#include "WechatHttpHandler.h"

#import <dlfcn.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#ifdef DEF_APLIPAY
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#endif

#include "PlatformUtils_ios.h"

bool WXApiHandler_ios::registerAppForIOS(const char* appID)
{
    return [WXApi registerApp:[NSString stringWithUTF8String:appID]];
}

bool WXApiHandler_ios::sendAuthRequestForIOS()
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[[SendAuthReq alloc ] init ] autorelease ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    return [WXApi sendReq:req];
}

void WXApiHandler_ios::onRespForIOS(const char* code)
{
    // CCLOG("%s",code);
    WechatHttpHandler::getInstance()->setWXCode(code);
    WechatHttpHandler::getInstance()->onHttpGetAccessToken();
}

void WXApiHandler_ios::onShareRespForIOS(const int errCode)
{
    WechatHttpHandler::getInstance()->onShareResp(errCode);
}

void WXApiHandler_ios::onPayRespForIOS(const int errCode)
{
    cocos2d::UserDefault::getInstance()->setIntegerForKey("platform_wechat_pay", errCode);
}

//MARK::分享Webpage
void WXApiHandler_ios::shareWebToWeixinForIOS(const char* title,const char* description,const char* image,const char* webpageUrl,int type)
{
    if (-1 == type) {
        PlatformUtils_ios::saveToPhotosAlbum(image);
        return ;
    }
    // 设置分享内容
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [NSString stringWithUTF8String:title];
    message.description = [NSString stringWithUTF8String:description];
    [message setThumbImage:[UIImage imageNamed:[NSString stringWithUTF8String:image]]];

    WXWebpageObject *obj = [WXWebpageObject object];
    obj.webpageUrl = [NSString stringWithUTF8String:webpageUrl];

    message.mediaObject = obj;

    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;

    req.scene = 0==type ? WXSceneSession : WXSceneTimeline;
    [WXApi sendReq:req];
}

//MARK::分享Image
void WXApiHandler_ios::shareImageToWeixinForIOS(const char* thumbImagepath,const char* imagepath,int type)
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:[NSString stringWithUTF8String:thumbImagepath]]];
    
    WXImageObject *imageObject = [WXImageObject object];
    imageObject.imageData = [NSData dataWithContentsOfFile:[NSString stringWithUTF8String:imagepath]];
    message.mediaObject = imageObject;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    
    req.scene = 0==type ? WXSceneSession : WXSceneTimeline;
    [WXApi sendReq:req];
    
}

void WXApiHandler_ios::jumpToWeixinPayForIOS(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp)
{
    //调起微信支付
    PayReq* req             = [[[PayReq alloc] init]autorelease];
    req.partnerId           = [NSString stringWithUTF8String:partnerId];
    req.prepayId            = [NSString stringWithUTF8String:prepayId];
    req.nonceStr            = [NSString stringWithUTF8String:nonceStr];
    req.timeStamp           = timeStamp;
    req.package             = [NSString stringWithUTF8String:package];
    req.sign                = [NSString stringWithUTF8String:sign];
    [WXApi sendReq:req];
}

void WXApiHandler_ios::jumpToAlipayForIOS(const char* outTradeNO,const char* totalFee)
{
#ifdef DEF_APLIPAY
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088021401946023";
    NSString *seller = @"136823298@qq.com";
    NSString *privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAKYfnzzcvbpCNPiEdSYbB6LOPXI3C7OhFRgNUPzHz1iXP0Fh60/nreLOQUVe2URfwIhkPiKslukMZ/aInBxdvhSrxQtYzMZ8VNwbWVhjwpKnAr4FHwgQrWCMO/2nF02t50V7i2ll5tsRocg9UENHLNymYgdYU2dxUZi2dO7YM159AgMBAAECgYBc/pC2kl+HN+7NO+EUjscMhWVyXYwoZ0EWsMWoa/YPgsN/R2Bh37DAqXNycPExTGTMNUlvQaxNE4vTP5AcdQGlSW7p18334oMA8KjK+JKuFTRP697ErD5XiDyqRouHmtr1j/idDhol0CwL4L/N8QEBilwfE+t3/O5zbU9ye6d2IQJBAO3qThy3uLYlWZbGCrb7CY0Dm8EbRH6ugV8J6wwnNoPxwBilJe6rJz3qYKjz6ujJ6LCr3N6TUYevY5QmqZtqQuUCQQCywEp01dCYWu4yaz0V9eKvbTeTN3IhbV6BkIlciREnOEMfzFx4QCXi5sN7BN8tUWZODgWwA5dGJrPMpTQD4Xu5AkEA7VLShHcH/DoZufrnaUvVZSL6VZC7rJqqVoFwQ/lBujCG7I6g3glA5dRMg3x9EaWHReTKOARASdc8v+YpPeyruQJAUKsG7wMvSBKBPK+4uZhl3NVlJ0L2dq9s3vvjgac53oE9ibQoZvxMHMIXpgTk0wbRLJiXaH+2XSpKKijD+JxhwQJBAN+KUZTbwyMf5WYob/0D+PJKKv+43bF9+78I9IfrVL1snBflNCm1U2N/PjC8lvT/8H05PmmloS193jFgmQIz8dI=";
    
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    order.outTradeNO = [NSString stringWithUTF8String:outTradeNO]; //订单ID
    order.subject = @"麻将帝国-游戏充值"; //商品标题
    order.body = @"麻将帝国-游戏充值"; //商品描述
    order.totalFee = [NSString stringWithUTF8String:totalFee];; //商品价格

    order.notifyURL =  @"http://123.56.252.147:82/index.php/HuaShuiPayCallBack_alipay"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alipaykaka4";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    // NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
#endif
}


const char* WXApiHandler_ios::getIMEIForIOS()
{
    const char *udid = [[GameUUID uniqueAppId] UTF8String];
    return udid;
}

// 0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown它返回的是0.00-1.00之间的浮点值。
float WXApiHandler_ios::getBatteryLevelForIOS()
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [UIDevice currentDevice].batteryLevel;
}


float WXApiHandler_ios::getWifiSignalLevelForIOS()
{
    UIApplication *app = [UIApplication sharedApplication];
    //NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSArray *subviews;
    // 不能用 [[self deviceVersion] isEqualToString:@"iPhone X"] 来判断，因为模拟器不会返回 iPhone X
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        　　subviews = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else {
        　　subviews = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }
    NSString *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            continue;
        }
    }
    int wifiStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    return wifiStrength/3.0;
    
    //    return [UIDevice currentDevice];
    
    //    void *libHandle = dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony",RTLD_LAZY);//获取库句柄
    //    int (*CTGetSignalStrength)(); //定义一个与将要获取的函数匹配的函数指针
    //    CTGetSignalStrength = (int(*)())dlsym(libHandle,"CTGetSignalStrength"); //获取指定名称的函数
    //
    //    if(CTGetSignalStrength == NULL)
    //        return -1;
    //    else{
    //        int level = CTGetSignalStrength();
    //        dlclose(libHandle); //切记关闭库
    //        return level;
    //    }
}

int WXApiHandler_ios::getWifiSignalStateForIOS()
{
    UIApplication *app = [UIApplication sharedApplication];
    //    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSArray *subviews;
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        　　subviews = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else {
        　　subviews = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }
    int networkType = 0;
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            break;
        }
    }
    switch (networkType) {
        case 0:
//            NSLog(@"NONE");
            break;
        case 1:
//            NSLog(@"2G");
            break;
        case 2:
//            NSLog(@"3G");
            break;
        case 3:
//            NSLog(@"4G");
            break;
        case 5:
        {
            //            NSLog(@"WIFI");
            return 3;
        }
            break;
        default:
            break;
    }
    return 1;
    
    //    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    //    CTCarrier *carrier = [info subscriberCellularProvider];
    //    NSString *mCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    //    NSString *mConnectType = [[NSString alloc] initWithFormat:@"%@",info.currentRadioAccessTechnology];
    //    if(CTRadioAccessTechnologyGPRS == mConnectType){
    //        return 0;
    //    }else
    //        return 1;
}

int WXApiHandler_ios::getMobileSignalStateForIOS()
{
    UIApplication *app = [UIApplication sharedApplication];
    //    NSArray *subviews = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    NSArray *subviews;
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        　　subviews = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else {
        　　subviews = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }
    int networkType = 0;
    for (id subview in subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
            break;
        }
    }
    //    switch (networkType) {
    //        case 0:
    //            NSLog(@"NONE");
    //            break;
    //        case 1:
    //            NSLog(@"2G");
    //            return 2;
    //            break;
    //        case 2:
    //            NSLog(@"3G");
    //            return 3;
    //            break;
    //        case 3:
    //            NSLog(@"4G");
    //            return 4;
    //            break;
    //        case 5:
    //        {
    //            NSLog(@"WIFI");
    //        }
    //            break;
    //        default:
    //            break;
    //    }
    return 0;
}

float WXApiHandler_ios::getMobileSignalLevelForIOS()
{
    UIApplication *app = [UIApplication sharedApplication];
    //    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSArray *subviews;
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        　　subviews = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else {
        　　subviews = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }
    NSString *dataSignalItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]) {
            dataSignalItemView = subview;
            break;
        }
    }
    int signalStrength = [[dataSignalItemView valueForKey:@"_signalStrengthBars"] intValue];
    return signalStrength/3.0;
}

#endif













