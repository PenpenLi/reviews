1.c++ 与 lua 绑定: tolua++,  
--https://blog.csdn.net/u011676589/article/details/48156369?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-11.nonecase&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-11.nonecase
{demo
    #include "stdafx.h"
    extern "C"
    {
        #include <lua.h>
        #include <lualib.h>
        #include <lauxlib.h>
    }
    lua_State *L;

    static int first_lua(lua_State *L) --for lua=c
    {
        int num = lua_tonumber(L, 1);
        std::count<<num<<std::endl;
        lua_pushstring(L, "Hello Lua");
    }

    int _tmain(int argc, _TCHAR* argv[]) 
    {
        L = luaL_newstate(); //注册一个状态机
        luaL_openlibs(L); //加载lua库

        lua_register(L, "first_lua", first_lua); --for lua=c
        luaL_dofile(L, "C:\\hellolua.lua"); -- c=lua
        lua_close(L);

        getchar();
        return 0;
    }
    --
    {
        local hello = first_lua(1) -- lua=c
        print("hello")
    }
}
{Lua堆栈:
栈的特点是先进后出
在Lua中，Lua堆栈就是一个struct，堆栈索引的方式可是是正数也可以是负数，
区别是：正数索引1永远表示栈底，负数索引-1永远表示栈顶
--
存入栈的数据类型包括数值, 字符串, 指针, table, 闭包等
lua_pushcclosure(L, func, 0) // 创建并压入一个闭包
lua_createtable(L, 0, 0)        // 新建并压入一个表
lua_pushnumber(L, 343)      // 压入一个数字
lua_pushstring(L, “mystr”)   // 压入一个字符串
--
从下面的图可以的得出如下结论:
. lua中, number, boolean, nil, light userdata四种类型的值是直接存在栈上元素里的, 和垃圾回收无关.
. lua中, string, table, closure, userdata, thread存在栈上元素里的只是指针, 他们都会在生命周期结束后被垃圾回收.
}
{lua调用c++：

}
{c++调用lua：
    --
    //1.创建一个state  
    lua_State *L = luaL_newstate();  
    //2.入栈操作  
    lua_pushstring(L, "I am so cool~");   
    lua_pushnumber(L,20);

    //3.取值操作  
    if( lua_isstring(L,1)){             //判断是否可以转为string  
        cout<<lua_tostring(L,1)<<endl;  //转为string并返回  
    }  
    if( lua_isnumber(L,2)){  
        cout<<lua_tonumber(L,2)<<endl;  
    }  
    //4.关闭state  
    lua_close(L); 
    //////////////////////////////////////////
    str = "I am so cool"  
    tbl = {name = "shun", id = 20114442}  
    function add(a,b)  
        return a + b  
    end
}


2.c++ 与 java 绑定: jni
{java调用c++
    public static native void onRespJNI(String code, int n_type);
    --
    extern "C"{
        //给android调用的native代码，微信回调后会调用这个函数
        JNIEXPORT void Java_org_cocos2dx_lua_AppActivity_onRespJNI(JNIEnv *env, jobject thiz, jstring code, jint n_type)
        {
            const char *szCode = env->GetStringUTFChars(code, NULL);
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
}
{c++调用java
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
    --
    public static void shareImageToWeixin(String thumbImagepath, String imagepath, int type)  throws IOException{
        
        if(mWeiXinApi.openWXApp())
        {
            boolean bhengping = (type / 2 == 0);
            Bitmap bmp = BitmapFactory.decodeFile(imagepath);
            Bitmap bmp2;
            if (bhengping) {
              bmp2 = Bitmap.createScaledBitmap(bmp, 960, 540, true);
            }else{
              bmp2 = Bitmap.createScaledBitmap(bmp, 540, 960, true);
            }
            WXImageObject imgObj = new WXImageObject(bmp2);
            WXMediaMessage msg = new WXMediaMessage();
            msg.mediaObject = imgObj;
            Bitmap thumbBmp;
            if (bhengping) {
             thumbBmp = Bitmap.createScaledBitmap(bmp, 128, 72, true);
            }else{
              thumbBmp = Bitmap.createScaledBitmap(bmp, 72, 128, true);
            } 
            msg.thumbData = bmpToByteArray(thumbBmp, true);
           
            SendMessageToWX.Req req = new SendMessageToWX.Req();
            req.transaction = String.valueOf(System.currentTimeMillis());
            req.message = msg;
            req.scene = type%2 == 0 ? SendMessageToWX.Req.WXSceneSession: SendMessageToWX.Req.WXSceneTimeline;
            mWeiXinApi.sendReq(req);
        }
        else
        {
             Toast.makeText(instance, "未安装微信", Toast.LENGTH_SHORT).show();
        }
    }
}

3.c++ 与 ios 绑定: .mm


4.c++ 与 js 绑定

