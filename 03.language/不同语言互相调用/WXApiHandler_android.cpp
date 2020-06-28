//
//  WXApiHandler.cpp
//  Test
//
//  Created by Lu on 16/5/28.
//
//
#include "WXApiHandler_android.h"

#include "WechatHttpHandler.h"
#include "PayMentHandler.h"
#include "YXHttpHandler.h"
#include "XLHttpHandler.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include "UtilAPI.h"
#endif

//MARK::微信 Android通过Jni调用java层接口

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

bool WXApiHandler_android::registerAppForAndroid(const char* appID)
{
    JniMethodInfo jni;
    bool ishave = JniHelper::getStaticMethodInfo(jni,"org/cocos2dx/lua/AppActivity","registerWeixin","(Ljava/lang/String;)V");
    
    if(ishave)
    {
        // 将C++的char*转换成java的jstring
        jstring str_id = jni.env->NewStringUTF(appID);
        jni.env->CallStaticVoidMethod(jni.classID,jni.methodID,str_id);
        jni.env->DeleteLocalRef(jni.classID);
        jni.env->DeleteLocalRef(str_id);
        
    }
    return true;
}

bool WXApiHandler_android::sendAuthRequestForAndroid()
{
    JniMethodInfo jni;
    bool ishave = JniHelper::getStaticMethodInfo(jni,"org/cocos2dx/lua/AppActivity","sendAuthRequest","()V");
    
    if(ishave)
    {
        jni.env->CallStaticVoidMethod(jni.classID,jni.methodID);
    }
    return true;
}

void WXApiHandler_android::shareWebToWeixinForAndroid(const char* title,const char* description,const char* image,const char* webpageUrl,int type)
{
    JniMethodInfo jni;
    bool ishave = JniHelper::getStaticMethodInfo(jni,"org/cocos2dx/lua/AppActivity","shareWebToWeixin","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
    
    if(ishave)
    {
        // 将C++的char*转换成java的jstring
        jstring str_title = jni.env->NewStringUTF(title);
        jstring str_description = jni.env->NewStringUTF(description);
        jstring str_image = jni.env->NewStringUTF(image);
        jstring str_webpageUrl = jni.env->NewStringUTF(webpageUrl);
        
        jni.env->CallStaticVoidMethod(jni.classID,jni.methodID,str_title,str_description,str_image,str_webpageUrl,type);
    }
}

void WXApiHandler_android::shareImageToWeixinForAndroid(const char* thumbImagepath,const char* imagepath,int type)
{
    JniMethodInfo jni;
    bool ishave = JniHelper::getStaticMethodInfo(jni,"org/cocos2dx/lua/AppActivity","shareImageToWeixin","(Ljava/lang/String;Ljava/lang/String;I)V");
    
    if(ishave)
    {
        // 将C++的char*转换成java的jstring
        jstring str_thumbImagepath = jni.env->NewStringUTF(thumbImagepath);
        jstring str_imagepath = jni.env->NewStringUTF(imagepath);
        
        jni.env->CallStaticVoidMethod(jni.classID,jni.methodID,str_thumbImagepath,str_imagepath,type);
    }

}

void WXApiHandler_android::jumpToWeixinPayForAndroid(const char* appId,const char* partnerId,const char* prepayId,const char* package,const char* sign,const char* nonceStr,int timeStamp)
{
    JniMethodInfo jni;
    bool ishave = JniHelper::getStaticMethodInfo(jni,"org/cocos2dx/lua/AppActivity","jumpToWeixinPay","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V");
    
    if(ishave)
    {
        // 将C++的char*转换成java的jstring
        jstring str_appId = jni.env->NewStringUTF(appId);
        jstring str_partnerId = jni.env->NewStringUTF(partnerId);
        jstring str_prepayId = jni.env->NewStringUTF(prepayId);
        jstring str_package = jni.env->NewStringUTF(package);
        jstring str_sign = jni.env->NewStringUTF(sign);
        jstring str_nonceStr = jni.env->NewStringUTF(nonceStr);
        
        jni.env->CallStaticVoidMethod(jni.classID,jni.methodID,str_appId,str_partnerId,str_prepayId,str_package,str_sign,str_nonceStr,timeStamp);
    }

}

void WXApiHandler_android::jumpToAlipayForAndroid(int payPlatform,const char* amountMoney, const char* orderCode,int userID)
{
    log("支付接口调用");
    JniMethodInfo jni;
    if (1 == payPlatform)    
    {
        //微信充值，改为用WXApiHandler::jumpToWeixinPayForAndroid
        
    }
    else if(0 == payPlatform)
    {
        // log("0 == payPlatform");
        if (JniHelper::getStaticMethodInfo(jni,"com/alipay/ZhiFuBaoPayManager","payZFB","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")) {
            jstring jMoney = jni.env->NewStringUTF(amountMoney);
            jstring juserID = jni.env->NewStringUTF(__String::createWithFormat("%d",userID)->getCString());
            jstring jorderCode = jni.env->NewStringUTF(orderCode);
            
            jni.env->CallStaticVoidMethod(jni.classID,jni.methodID,jMoney,jorderCode,juserID);
            jni.env->DeleteLocalRef(jni.classID);
            jni.env->DeleteLocalRef(jMoney);
            jni.env->DeleteLocalRef(jorderCode);
            jni.env->DeleteLocalRef(juserID);
            
        }
        
    }
}

float WXApiHandler_android::getBatteryLevelForAndroid()
{
    JniMethodInfo jni;
    
    if (JniHelper::getStaticMethodInfo(jni, "org/cocos2dx/lua/AppActivity", "getDeviceBatteryLevel", "()F")) {
        jfloat batteryLevel ;
        batteryLevel = jni.env->CallStaticFloatMethod(jni.classID, jni.methodID);
        
        
        return batteryLevel;
    }
    
    return 100;
}

float WXApiHandler_android::getWifiSignalLevelForAndroid()
{
    JniMethodInfo jni;
    
    if (JniHelper::getStaticMethodInfo(jni, "org/cocos2dx/lua/AppActivity", "getDeviceSignalLevel", "()F")) {
        jfloat batteryLevel ;
        batteryLevel = jni.env->CallStaticFloatMethod(jni.classID, jni.methodID);
        
        return batteryLevel;
    }
    
    return 0.0f;
}
int WXApiHandler_android::getWifiSignalStateForAndroid()
{
    JniMethodInfo jni;
    
    if (JniHelper::getStaticMethodInfo(jni, "org/cocos2dx/lua/AppActivity", "getDeviceSignalState", "()I")) {
        jint batteryLevel ;
        batteryLevel = jni.env->CallStaticIntMethod(jni.classID, jni.methodID);
        
        return batteryLevel;
    }
    
    return 0;
}
float WXApiHandler_android::getMobileSignalLevelForAndroid()
{
    JniMethodInfo jni;
    
    if (JniHelper::getStaticMethodInfo(jni, "org/cocos2dx/lua/AppActivity", "getDeviceMobileLevel", "()F")) {
        jfloat batteryLevel ;
        batteryLevel = jni.env->CallStaticFloatMethod(jni.classID, jni.methodID);
        
        return batteryLevel;
    }
    
    return 0.0f;
}
int WXApiHandler_android::getMobileSignalStateForAndroid()
{
    JniMethodInfo jni;
    
    if (JniHelper::getStaticMethodInfo(jni, "org/cocos2dx/lua/AppActivity", "getDeviceMobileState", "()I")) {
        jint batteryLevel ;
        batteryLevel = jni.env->CallStaticIntMethod(jni.classID, jni.methodID);
        
        return batteryLevel;
    }
    
    return 0;
}
const char* WXApiHandler_android::getIMEIForAndroid()
{
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, "org/cocos2dx/lua/AppActivity", "getDeviceId", "()Ljava/lang/String;")) {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        CCString *ret = new CCString(JniHelper::jstring2string(str).c_str());
        ret->autorelease();
        t.env->DeleteLocalRef(str);
        return ret->getCString();
    }
    return "";
}
    
extern "C"{
    //给android调用的native代码，微信回调后会调用这个函数
    JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onRespShareJNI(JNIEnv *env, jobject thiz, jint code, jint n_type)
    {
        if (0 == n_type) {
            WechatHttpHandler::getInstance()->onShareResp(code);
        }
        else if (1 == n_type) {
            YXHttpHandler::getInstance()->onShareResp(code);
        }
        else if (2 == n_type) {
            XLHttpHandler::getInstance()->onShareResp(code);
        }
    }
}

extern "C"{
    //给android调用的native代码，微信回调后会调用这个函数
    JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onRespJNI(JNIEnv *env, jobject thiz, jstring code, jint n_type)
    {
        const char *szCode = env->GetStringUTFChars(code, NULL);
//        log("----code---%s",szCode);
        if (0 == n_type) {
            WechatHttpHandler::getInstance()->setWXCode(szCode);
            WechatHttpHandler::getInstance()->onHttpGetAccessToken();
        }
        else if (1 == n_type) {
            YXHttpHandler::getInstance()->setWXCode(szCode);
            YXHttpHandler::getInstance()->onHttpGetAccessToken();
        }
        else if (2 == n_type) {
            XLHttpHandler::getInstance()->setWXCode(szCode);
            XLHttpHandler::getInstance()->onHttpGetAccessToken();
        }
    }
}

extern "C"{
    //支付回调
    JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onPayResult(JNIEnv *env, jobject thiz, jint result)
    {
//        log("支付回调code::%d",result);
        cocos2d::UserDefault::getInstance()->setIntegerForKey("platform_wechat_pay", result);
    }
}

extern "C"{
    //给android调用的native代码，船只
    JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onWechatJoinRoom(JNIEnv *env, jobject thiz, jstring game, jstring room)
    {
        const char *s_game = env->GetStringUTFChars(game, NULL);
        const char *s_room = env->GetStringUTFChars(room, NULL);
//        WXApiHandler::setJoinRoomID(s_game, s_room);
        
        WechatHttpHandler::getInstance()->m_s_wxJoinGameid = s_game;
        WechatHttpHandler::getInstance()->m_s_wxJoinRoomid = s_room;
        
        if (WechatHttpHandler::getInstance()->m_s_wxJoinGameid == "" && WechatHttpHandler::getInstance()->m_s_wxJoinRoomid == ""){
            WechatHttpHandler::getInstance()->m_s_wxJoinGameid = cocos2d::UserDefault::getInstance()->getStringForKey("android_joingameid", "");
            WechatHttpHandler::getInstance()->m_s_wxJoinRoomid = cocos2d::UserDefault::getInstance()->getStringForKey("android_joinroomid", "");
            cocos2d::UserDefault::getInstance()->setStringForKey("android_joingameid", "");
            cocos2d::UserDefault::getInstance()->setStringForKey("android_joinroomid", "");
            
        }else{
            cocos2d::UserDefault::getInstance()->setStringForKey("android_joingameid", s_game);
            cocos2d::UserDefault::getInstance()->setStringForKey("android_joinroomid", s_room);
        }
    }
    JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onWechatJoinExit(JNIEnv *env, jobject thiz)
    {
        cocos2d::Director::getInstance()->end();
    }
}

#endif
//net.sourceforge.simcpux.wxapi


