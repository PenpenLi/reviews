--[[
0.索引
--]]

--[[
android:{
    public static void showXXViewUrl(final String url__, final String param__, final int callback) {
		//webview
		_AppActivity.runOnUiThread(new Runnable() {
			private String url = url__; //"https://b00201.appxb.me/mobile/index.do";
			private String param = param__; //"SESSION=1ab7381e-af82-489f-93f2-fcf831892341";
			//			private String url = "https://www.google.com/";
//			private String param = "SESSION=1ab7381e-af82-489f-93f2-fcf831892341";
			@Override
			public void run() {
				// 建立WebView
				// 实例化WebView对象
				webView_ = new WebView(_AppActivity);
				// 设置WebView属性，能够执行Javascript脚本
				webView_.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
				webView_.setHorizontalScrollbarOverlay(true);
				webView_.setHorizontalScrollBarEnabled(true);
				webView_.setBackgroundColor(0);
				webView_.setBackgroundColor(Color.WHITE);
				webView_.setAlpha(0);
				webView_.requestFocus();
				UnSafeWebViewClient unClient = new UnSafeWebViewClient();
				unClient.setActivity(_AppActivity);
				webView_.setWebViewClient(unClient);
				FrameLayout.LayoutParams lParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
						FrameLayout.LayoutParams.MATCH_PARENT);
				_AppActivity.mFrameLayout.addView(webView_, lParams);
				WebSettings webSettings = webView_.getSettings();
				webSettings.setJavaScriptEnabled(true);
				webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
				webSettings.setDomStorageEnabled(true);
				webSettings.setDatabaseEnabled(true);
				webSettings.setLoadsImagesAutomatically(true);
				webSettings.setAppCacheEnabled(true);
				webSettings.setAllowFileAccess(true);
				webSettings.setAllowFileAccessFromFileURLs(true);
				webSettings.setAllowUniversalAccessFromFileURLs(true);
				webSettings.setAllowContentAccess(true);
				webSettings.setSavePassword(true);
				webSettings.setSupportZoom(true);
				webSettings.setBuiltInZoomControls(true);
				webSettings.setUseWideViewPort(true);
				webSettings.setAppCacheEnabled(true);
				webSettings.setSaveFormData(true);// 設置儲存
				if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
					webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
				}
				if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
					webSettings.setAllowFileAccessFromFileURLs(true);
				}
				webSettings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
				webSettings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
				webView_.setWebChromeClient(new WebChromeClient());
				webView_.setWebViewClient(new WebViewClient() {
					@Override
					public boolean shouldOverrideUrlLoading(WebView view, String url) { return false; }
					@Override
					public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {handler.proceed();}
					@Override
					public void onPageFinished(WebView view, String url) {
						super.onPageFinished(view, url);
						//
						CookieManager cm = CookieManager.getInstance();
						String strCookie = cm.getCookie(url);
						Log.v("strCookie_onPage", strCookie + url);
						//
						if (view.getAlpha() == 0) {
							new Handler().postDelayed(new Runnable() {
								@Override
								public void run() {
									// 要延时的程序
									webView_.setAlpha(1);
								}
							}, 500); // 毫秒单位
						}
					}
				});
				// SESSION COOKIE=======================================================
				Uri uri = Uri.parse((String) url);
				String sInfo = param + ";domain=" + uri.getHost() + ";path=/";
				Log.v("strCookie_infos", "sss" + sInfo);
				List<String> cookies = new ArrayList<>();
				//键值对类型  用等号（"="）连接    具体根据后台给定
				cookies.add(sInfo);//根据后台协商而定
				//
				//5.0以上需要开启第三方Cookie存储
				if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
					CookieManager.getInstance().setAcceptThirdPartyCookies(webView_, true);
				}
				CookieSyncManager.createInstance(_AppActivity.getApplicationContext());
				CookieManager cm = CookieManager.getInstance();
				cm.setAcceptCookie(true);
				cm.removeSessionCookie();// 移除
				cm.removeAllCookie();
				cm.setCookie(url, sInfo);
//				if (cookies != null) {
//					for (String cookie : cookies) {
//						cm.setCookie(url, cookie);//注意端口号和域名，这种方式可以同步所有cookie，包括sessionid
//					}
//				}
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
					CookieManager.getInstance().flush();
				} else {
					CookieSyncManager.getInstance().sync();
				}
				String strCookie = cm.getCookie(url);
				Log.v("strCookie_infos", "" + strCookie);
				webView_.loadUrl(url);
				// 关闭按钮
				addFloatBtn(callback);
				// run end
			}
		});
	}

	public static void closeXXViewUrl(String url, String param, final int callback) {
//		_AppActivity.closeXXViewUrl(url, param, callback);
		_AppActivity.removeWebView();
	}
}
ios:{
    
}
--]]
- (void)wkwebViewCookieUrl:(NSString*)hostUrl webViewCookieParam:(NSString*)hostParam{
    //
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie]; // 保存
    }
    //
    NSURL *sURL = [NSURL URLWithString:hostUrl];
    NSString *sDomain = sURL.host;
    NSString *sPath =  @"/";
    NSArray *array = [hostParam componentsSeparatedByString:@"="];
    NSDictionary *propertiesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    sDomain, NSHTTPCookieDomain,
                                    sPath, NSHTTPCookiePath,
                                    array[0], NSHTTPCookieName,
                                    array[1], NSHTTPCookieValue,
                                    nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:propertiesDict];
    NSLog(@"========sdsd====%@, %@", array, cookie);
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie]; // 保存
    
    // 寻找URL为HOST的相关cookie，不用担心，步骤2已经自动为cookie设置好了相关的URL信息
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:hostUrl]];
    // 这里的HOST是你web服务器的域名地址，那么这里的HOST就是http://abc.com
    // 设置header，通过遍历cookies来一个一个的设置header
    for (NSHTTPCookie *cookie in cookies){
        // cookiesWithResponseHeaderFields方法，需要为URL设置一个cookie为NSDictionary类型的header，
        // 注意NSDictionary里面的forKey需要是@"Set-Cookie"
        NSArray *headeringCookie =
        [NSHTTPCookie cookiesWithResponseHeaderFields:
         [NSDictionary dictionaryWithObject:
          [[NSString alloc] initWithFormat:
           @"%@=%@;domain=%@;path=%@",[cookie name],[cookie value],[cookie domain],[cookie path]]
                                     forKey:@"Set-Cookie"]
                                               forURL:[NSURL URLWithString:hostUrl]];
        // 通过setCookies方法，完成设置，这样只要一访问URL为HOST的网页时，会自动附带上设置好的header
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie
                                                           forURL:[NSURL URLWithString:hostUrl]
                                                  mainDocumentURL:nil];
    }
}

- (void)wkwebViewCookieUrl_ajaxsetting:(NSString*)hostUrl webViewCookieParam:(NSString*)hostParam webviewConfig:(WKWebViewConfiguration*)config {
    //应用于 ajax 请求的 cookie 设置
    NSURL *sURL = [NSURL URLWithString:hostUrl];
    WKUserContentController *userContentController = [WKUserContentController new];
    NSString *cookieSource = [NSString stringWithFormat:@"document.cookie = '%@;domain=%@;path=/';", hostParam,sURL.host];
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieSource injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:cookieScript];
    config.userContentController = userContentController;
}

- (void)wkwebViewCookieUrl_ajaxrequest:(NSString*)hostUrl webViewCookieParam:(NSString*)hostParam{
    // 应用于 request 的 cookie 设置
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:hostUrl]];
    NSArray *array = [hostParam componentsSeparatedByString:@"="];
    NSDictionary *headFields = request.allHTTPHeaderFields;
    NSString *cookie = headFields[array[0]];
    if (cookie == nil) {
        NSURL *sURL = [NSURL URLWithString:hostUrl];
        NSString *sDomain = sURL.host;
        NSString *sPath =  @"/";
        NSString *sInfo = [[NSString alloc] initWithFormat:@"%@;domain=%@;path=%@",hostParam,sDomain,sPath];
        [request addValue:sInfo forHTTPHeaderField:@"Cookie"];
    }
    [shareWebview loadRequest:request];
}

- (void)initView:(NSString*)OpenURL initParam:(NSString*)OpenParam callback:(int)callback{
//    xxController = self;
    if (OpenURL == nil || [OpenURL  isEqual: @""]) OpenURL = @"https://b00201.appxb.me/mobile/index.do";
    if (OpenParam == nil || [OpenParam  isEqual: @""] || [OpenParam  isEqual: @"SESSION="]) OpenParam = @"SESSION=decc96c6-3cf0-4658-8703-380266263963";
    webviewCallback = callback;
    
    //webViewCookieUrl
    UIView *obj = [[[UIApplication sharedApplication] windows] lastObject];
    [self wkwebViewCookieUrl:OpenURL webViewCookieParam:OpenParam];
    
    //WKWebViewConfiguration
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    [configuration.preferences setValue:@"TRUE" forKey:@"allowFileAccessFromFileURLs"];
    //
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.preferences = preferences;
    //应用于 ajax 请求的 cookie 设置
    [self wkwebViewCookieUrl_ajaxsetting:OpenURL webViewCookieParam:OpenParam webviewConfig:configuration];
    
    //WKWebview
    WKWebView *webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
    [webView setBackgroundColor: [UIColor clearColor]];
    [webView setOpaque:NO];
//    [webView setAlpha:0];
    // 将WKWebView添加到视图
    [obj addSubview:webView];
    webView.scrollView.bounces=NO;
    webView.UIDelegate = sharedInstance;
    webView.navigationDelegate = sharedInstance;
    shareWebview = webView;
    
    // WKWebView加载请求
    [self wkwebViewCookieUrl_ajaxrequest:OpenURL webViewCookieParam:OpenParam];
    
    //创建可拖动、自动贴近边缘的 事件上报按钮
    [self initAddMoreEventBtn];
    
    //
    [self resetLayout:[UIScreen mainScreen].bounds.size];
}

--[[
999.待定内容
--]]
