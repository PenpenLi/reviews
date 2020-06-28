--[[
0.索引
1.安卫士
2.七牛云推流
3.相机相册
4.截图
5.安卓应用内下载
6.安卓修改输入框
7.BG视讯
8.单独界面横竖屏切换
9.umeng推送
10.苹果签名
11.极光推送
12.悬浮移动按钮
13.键盘处理
14.保存图片到相册
15.微信sdk更换
16.内嵌支付网页
999.待定内容
--]]

--[[
1.安卫士
https://www.anweishi.com/
有源码SDK调用
--]]

--[[
2.七牛云推流
http://rcca.11hk.com/player1
https://developer.qiniu.com/pili/sdk/5028/push-the-sdk-download-experience
--]]

--[[
3.相册相机
--]]

--[[
4.截图
android:{
	Android imagereader获取图像数据并保存本地
	安卓视频录-MediaProjection
}
--]]

--[[
5.安卓应用内下载
--]]

--[[
6.安卓修改输入框
Getviewtreeobject-addongloballayoutlistener
--]]

--[[
7.BG视讯
https://gitlab.com/BGVideoTeam/h5preloaddemo
android:{
    webview, 
    预加载，android所使用NanoHTTPD 本地web service; 
}
ios:{
    wkwebview
    预加载，ios所使用CocoaHttpServer 本地web service;
}
--]]

--[[
8.单独界面横竖屏切换
android:{
    AndroidManifest.xml Activity 
    src Activity setRequestedOrientation
}
ios:{
    general
    rootview:shouldAutorotateToInterfaceOrientation supportedInterfaceOrientations
    rechargeview: 上2+ viewWillTransitionToSize
}
--]]

--[[
9.umeng推送
https://developer.umeng.com/docs?spm=a211g2.211692.0.0.430d7d232jBzHq
android:{
    添加application
    push AndroidManifest.xml 
} 
ios:{
    p12 证书
}
--]]

--[[
10.苹果签名
https://www.bifu5.com/#/
https://dev.app2.cn/login
https://www.openinstall.io/
企业签名：容易掉，签名不准
超级签名：贵
TF签名：要过审核  
QQ:1901271242;QQ:3361739342
--]]

--[[
11.极光推送
ios:{
    //通知授权 https://www.jianshu.com/p/f0e9cbcef036
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions types10 = UNAuthorizationOptionBadge|UNAuthorizationOptionAlter|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10 completionHandler:^(BOOL granted, NSError *_Nullable error){
        if (granted) {
            NSLog(@"u push granted!");
        }else{
            NSLog(@"u push not granted!");
        }
    }]
    - (void)applicationWillEnterForeground:(UIApplication *)application {
        // Clear application badge when app launches
        [JPUSHService setBadge:0];
        [application setApplicationIconBadgeNumber:0];
        [application cancelAllLocalNotifications];
        //
        cocos2d::Application::getInstance()->applicationWillEnterForeground();
    }
    Info.plist
    archives: 档案
    Architectures: armv7 and arm64
    p12签名
    certificates: 证书 - 电脑
    identifier: 身份标识 - 应用id
    profiles:
}
--]]

--[[
12.悬浮移动按钮
android:{
    import com.google.android.material.floatingactionbutton.FloatingActionButton;
}
ios:{
    [self resetLayout:[UIScreen mainScreen].bounds.size];
    //按钮
    [spButton addTarget:self action:@selector(addMoreClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    //添加手势
    UIPanGestureRecognizer *panRcognize=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panRcognize setMinimumNumberOfTouches:1];
    [panRcognize setEnabled:YES];
    [panRcognize delaysTouchesEnded];
    [panRcognize cancelsTouchesInView];
    [btn addGestureRecognizer:panRcognize];
    //事件 平移手势
    - (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
    {
        // 将WKWebView添加到视图
        UIView *obj = [[[UIApplication sharedApplication] windows] lastObject];
        //移动状态
        UIGestureRecognizerState recState =  recognizer.state;
        float SCREEN_WIDTH = [[UIScreen mainScreen] bounds].size.width;
        float SCREEN_HEIGHT = [[UIScreen mainScreen] bounds].size.height;
        switch (recState) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            breaK;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
        }
        [recognizer setTranslation:CGPointMake(0, 0) inView:obj];
    }
}
--]]

--[[
13.键盘处理
ios:{
    *.输入框附加视图
    ui/widgets/uieditbo/uieditboximpl-ios.mm
    textField_.inputAccessoryView = self.myToolbar;
    创建UIToobar,UITextView
    - (UIToolbar *)myToolbar
    {
        if (_myToolbar == nil) {
            float fwidth = [UIScreen mainScreen].bounds.size.width;
            CGRect tempFrame = CGRectMake(0, 0, fwidth, 44);
            _myToolbar = [[UIToolbar alloc] initWithFrame:tempFrame];
            
            UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(7,7,fwidth-14,30)];
            textview.backgroundColor=[UIColor whiteColor];//背景色
            textview.scrollEnabled=NO;//当文字超过视图的边框时是否允许滑动，默认为“YES”
            textview.editable=NO;//是否允许编辑内容，默认为“YES”
            textview.font=[UIFont fontWithName:@"Arial" size:18.0];//设置字体名字和字体大小;
            textview.textAlignment=NSTextAlignmentLeft;//文本显示的位置默认为居左
            textview.dataDetectorTypes=UIDataDetectorTypeAll;//显示数据类型的连接模式（如电话号码、网址、地址等）
            textview.textColor= [UIColor blackColor];
            textview.text=@"";//设置显示的文本内容
            [_myToolbar addSubview:textview];
            _myTextView = textview;
            
    //        UIImage *closeImg = [UIImage imageNamed:@"close"];
    //        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:closeImg style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked:)];
    //        _myToolbar.items = @[closeItem];
        }
        return _myToolbar;
    *.屏幕上移动
    platform/ios/CCEAGLView-ios.mm
    didMoveToWindow
    ui/widgets/UITextField.cpp
    keyboardWillShow
}
--]]

--[[
14.保存图片到相册
ios:{
    保存到相册
    NSFileManager *fileManager = [NSFildManager defaultManager];
    if (fileManager fileExistsAtPath:path) {
        UIAlertView *alertView = [[UIAlterView alloc] initWithTitle:@"提示" message:@"图片不存在" delegate:nil cancelButton:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }else{
        UIImage *image = [UIImage iamgeWithContentsOfFile:path];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil);
        
        [alertView show];
        [alertView release];
    }
}
android:{
    //保存文件到指定路径
    public static boolean saveImageToGallery(String bmpPath, String bmpName, int callback) {
        //
//      Log.v("saveImageToGallery", bmpPath + bmpName + callback);
        Context context = _AppActivity;
        File imgFile = new File(bmpPath);
        if (!imgFile.exists()) {
            return false;
        }
        //插入图片到系统相册
        try {
            MediaStore.Images.Media.insertImage(context.getContentResolver(), bmpPath, "图片", "图片");
            //保存图片后发送广播通知更新数据库
            Uri uri = Uri.parse(bmpPath);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));

            _AppActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    AlertDialog.Builder builder  = new AlertDialog.Builder(_AppActivity);
                    builder.setTitle("提示" ) ;
                    builder.setMessage("图片保存成功" ) ;
                    builder.setPositiveButton("确认" ,  null );
                    builder.show();
                }
            }); // 毫秒单位

            return true;
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return false;
    }
}
--]]

--[[
15.微信sdk更换
ios:{
    Scheme 方案；badge 徽章；
    URL Scheme 白名单
    LSApplicationQueriesSchemes: weixinULAPI
    Other Linker Flags: -Objc -force_load
    class-dump 检测包内uiwebview
}
]]

--[[
16.内嵌支付网页
    Intent WebView
    //专注 意图
    Intent it = new Intent(_AppActivity, RechargeActivity.class);
    it.putExtra("url", url);
    _AppActivity.startActivity(it);
    //类中接收参数
    Intent it = getIntent();
    String url = it.getStringExtra("url");

    //帧动画
    ImageView iv = (ImageView) findViewById(R.id.iv);
    //获取背景，并将其强转成 AnimationDrawable
    final AnimationDrawable ad = (AnimationDrawable)iv.getBackground();
    if (!ad.isRunning()) {
        ad.start();
    }
    new Handler().postDelayed(new Runnable() {
        @Override
        public void run(){
            ad.stop();
            ad.setAlpha(0);
        }
    })
    // loading.xml; duration 持续时间
    <?xml version="1.0" encoding="utf-8"?>
    <animation-list xmlns:android="http://schemas.android.com/apk/res/android" android:oneshot="true">
        <item android:drawable="@drawable/loading_1_00" android:duration="80">
    </animation-list>
--]]

--[[
17.安卓编译命令
    下载 ANT JDK SDK NDK
    环境变量 ANT_ROOT JAVA_HOME相关 NDK_ROOT ANDROID_SDK_ROOT COCOS_CONSOLE_ROOT COCOS_X_ROOT COCOS_TEMPLATES_ROOT
    可借助 setup.py 检验配置
    cocos compile -p android --ap 20
--]]


--[[
999.待定内容
    电量和网络
    钉钉，闲聊，易信，分享登录
    畅付云，口袋支付，
    星期天支付
    支付宝支付
    苹果商店支付
    微信支付分享登录
    高德定位
    美洽客服
    亲加语音
    腾讯云语音
    数据库sqlite
    网页透明背景

    权限检测和跳转
    录音ios
    安卓cocos去掉黑屏
    安卓减小包体：架构支持armeabi-v7a
    Android 当应用的targetSdk版本低于17时，应用启动时会弹窗“此应用专为旧版Android打造”
--]]






