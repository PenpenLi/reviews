/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.NetworkInterface;
import java.net.URL;
import java.net.URLConnection;
import java.util.Enumeration;
import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.provider.Settings;
import android.text.format.Formatter;
import android.text.TextUtils;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;

import net.sourceforge.decylshmj.R;

import com.alipay.PayResult;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXImageObject;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import android.content.pm.ApplicationInfo;  
import android.content.pm.PackageInfo;  
import android.content.pm.PackageManager;
import com.tencent.gcloud.voice.GCloudVoiceEngine;
import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;

import java.util.Date;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.location.LocationManagerProxy;
import com.amap.api.location.LocationProviderProxy;

import android.hardware.SensorManager;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.view.View;  

import im.yixin.sdk.api.IYXAPI;
import im.yixin.sdk.api.SendMessageToYX;
import im.yixin.sdk.api.BaseReq;
import im.yixin.sdk.api.SendAuthToYX;
import im.yixin.sdk.api.YXAPIFactory;
import im.yixin.sdk.api.YXImageMessageData;
import im.yixin.sdk.api.YXMessage;
import im.yixin.sdk.api.YXMusicMessageData;
import im.yixin.sdk.api.YXTextMessageData;
import im.yixin.sdk.api.YXVideoMessageData;
import im.yixin.sdk.api.YXWebPageMessageData;
import im.yixin.sdk.util.BitmapUtil;
import im.yixin.sdk.util.YixinConstants;

import com.android.dingtalk.share.ddsharemodule.DDShareApiFactory;
import com.android.dingtalk.share.ddsharemodule.IDDShareApi;
import com.android.dingtalk.share.ddsharemodule.message.SendMessageToDD;
import com.android.dingtalk.share.ddsharemodule.message.DDImageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDMediaMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDTextMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDWebpageMessage;
import com.android.dingtalk.share.ddsharemodule.message.DDZhiFuBaoMesseage;

import org.xianliao.im.sdk.api.ISGAPI;
import org.xianliao.im.sdk.api.SGAPIFactory;
import org.xianliao.im.sdk.constants.SGConstants;
import org.xianliao.im.sdk.modelmsg.SGImageObject;
import org.xianliao.im.sdk.modelmsg.SGGameObject;
import org.xianliao.im.sdk.modelmsg.SGMediaMessage;
import org.xianliao.im.sdk.modelmsg.SGTextObject;
// import org.xianliao.im.sdk.modelmsg.SendAuth;
import org.xianliao.im.sdk.modelmsg.SendMessageToSG;

import java.io.FileNotFoundException;
import java.io.File;
import java.io.FileOutputStream;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore; 
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.app.KeyguardManager;

import com.android.sdklibrary.admin.SdkBuilder;
import com.android.sdklibrary.admin.SdkDirector;
import com.android.sdklibrary.admin.SdkImplBuilder;

public class AppActivity extends Cocos2dxActivity{

    static String hostIPAdress = "0.0.0.0";

    public static AppActivity instance;//类静态实例，为了方便后面静态函数的调用
    private static IWXAPI mWeiXinApi;//微信API接口 api
    public static String mWeiXinAppid; //APP_ID
    public static IYXAPI mYiXinApi;
    public static String mYiXinAppid = ""; 
    private static IDDShareApi iddShareApi;
    public static String mDingTalkAppid = ""; 
    public static ISGAPI mXianLiaoApi;
    public static String mXianLiaoAppid;
    //hhd
    private static final int SDK_PAY_FLAG = 1;
    private static final int SDK_CHECK_FLAG = 2;
    private static float batteryLevel = 0;//电池电量0--1；
    private static int wifiSignalState = 0;
    private static float wifiSignalLevel = 0;//wifi信号强度0--1；
    private static IntentFilter wifiIntentFilter = null; 
    private static BroadcastReceiver wifiIntentReceiver = null;
    private static int mobileSignalState = 0;
    private static float mobileSignalLevel = 0;//mobile信号强度0--1；
    private static TelephonyManager telephoneManager = null;
    private static PhoneStateListener phoneStateListener = null;
    private static Handler xxmHandler = new Handler();
    private static int mMapLoopTimes = 0;
    private WakeLock mWakeLock;
        
    class BatteryReceiver extends BroadcastReceiver{ 
        @Override 
        public void onReceive(Context context, Intent intent) { 
            // TODO Auto-generated method stub 
            //判断它是否是为电量变化的Broadcast Action 
            if(Intent.ACTION_BATTERY_CHANGED.equals(intent.getAction()))
            { 
                //获取当前电量 
                int level = intent.getIntExtra("level", 0); 
                //电量的总刻度 
                int scale = intent.getIntExtra("scale", 100); 
                batteryLevel = (float)(level*1.0)/scale;
                
                setWifiSignal();
                setMobileSignal();
            } 
        } 
    }
    private static Handler mHandler = new Handler() {
        public void handleMessage(Message msg) {
            switch (msg.what) {
            case SDK_PAY_FLAG:
                PayResult payResult = new PayResult((String) msg.obj);
                String resultInfo = payResult.getResult();
                String resultStatus = payResult.getResultStatus();
                if (TextUtils.equals(resultStatus, "9000")) {
                    Toast.makeText(AppActivity.instance, "支付成功", Toast.LENGTH_SHORT)
                            .show();
                    AppActivity.onPayResult(0);
                } else {

                    if (TextUtils.equals(resultStatus, "8000")) {
                        Toast.makeText(AppActivity.instance, "支付结果确认中",
                                Toast.LENGTH_SHORT).show();
                        AppActivity.onPayResult(-2);
                    } else {
                        // 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
                        Toast.makeText(AppActivity.instance, "支付失败",
                                Toast.LENGTH_SHORT).show();
                        AppActivity.onPayResult(-1);
                    }
                }
                break;
            case SDK_CHECK_FLAG:
                Toast.makeText(AppActivity.instance, "检查结果为：" + msg.obj,
                        Toast.LENGTH_SHORT).show();
                break;
            }

        };
    };
    public static Handler getmHandler() {
        return mHandler;
    }
    public static void setmHandler(Handler mHandler) {
        AppActivity.mHandler = mHandler;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        
        //2.Set the format of window
        
        // Check the wifi is opened when the native is debug.
        if(nativeIsDebug())
        {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            if(!isNetworkConnected())
            {
                AlertDialog.Builder builder=new AlertDialog.Builder(this);
                builder.setTitle("Warning");
                builder.setMessage("Please open WIFI for debuging...");
                builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                    
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                        finish();
                        System.exit(0);
                    }
                });

                builder.setNegativeButton("Cancel", null);
                builder.setCancelable(true);
                builder.show();
            }
            hostIPAdress = getHostIpAddress();
        }

        //--------------------------
        instance = this;
        // when open by browser
        Intent intent = getIntent();
        handleIntent(intent);

        //注册广播接受者java代码 
        IntentFilter intentFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED); 
        //创建广播接受者对象 
        BatteryReceiver batteryReceiver = new BatteryReceiver(); 
        //注册receiver 
        registerReceiver(batteryReceiver, intentFilter); 
        //wifi signal & mobile signal
        setWifiSignal();
        setMobileSignal();
        //gcloudvoice
        GCloudVoiceEngine.getInstance().init(getApplicationContext(), this);

        // heheda
        Runnable r = new Runnable() {
           @Override
           public void run() {
               //do something
               onHideSoftButton();
               xxmHandler.postDelayed(this, 2000);
           }
       }; 
      onHideSoftButton();
       xxmHandler.postDelayed(r, 2000);
    }

    //------------OVERRIDE-------------------------------------------------------------------
    @Override 
    protected void onPause() {  
        super.onPause(); 
        stopAmap();
    }   

    @Override 
    protected void onResume() { 
        super.onResume();  
        startAmap();
    }

    @Override 
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        switch (requestCode) {  
            case 101:  
              System.exit(0);            
              break;
            default:  
                break; 
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        setIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        String action = intent.getAction();
        if (Intent.ACTION_VIEW.equals(action)) {
            Uri uri = intent.getData();
            if (uri != null && "" != uri.getQueryParameter("title")) {
                String title = uri.getQueryParameter("title");
                String game = uri.getQueryParameter("game");
                String room = uri.getQueryParameter("room");
                // Toast.makeText(this, "title=" + title + ",game=" + game + ",room="+ room, Toast.LENGTH_SHORT).show();
                AppActivity.onWechatJoinRoom(game, room);
                startAPP();
                // restartApplication();
                // AppActivity.onWechatJoinExit();
                // android.os.Process.killProcess(android.os.Process.myPid());
                // System.exit(0);
                // ActivityManager activityMgr = (ActivityManager)getSystemService(ACTIVITY_SERVICE);
                // activityMgr.killBackgroundProcesses(getPackageName());
            }else {
                AppActivity.onWechatJoinRoom("", "");
            }
        }else{
            String title = intent.getStringExtra("title");
            String game = intent.getStringExtra("game");
            String room = intent.getStringExtra("room");
            if (null == game) game = "";
            if (null == room) room = "";
            AppActivity.onWechatJoinRoom(game, room);
            // Log.v("sssssss", "Intent_get---------------" + title + game + room);
        }
    }
   //--------------------DEVICE-------------------------------   
    private void acquireWakeLock() {
        if(mWakeLock == null) {
            PowerManager pm = (PowerManager)getSystemService(Context.POWER_SERVICE);
            mWakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, 
                this.getClass().getCanonicalName());
            mWakeLock.acquire();
     
        }
     
    }
     
    private void releaseWakeLock() {
        if(mWakeLock != null) {
            mWakeLock.release();
            mWakeLock = null;
        }
    }
    /**
     * 唤醒手机屏幕并解锁
     */
    public static void wakeUpAndUnlock() {
        // 获取电源管理器对象
        PowerManager pm = (PowerManager) instance.getContext()
                .getSystemService(Context.POWER_SERVICE);
        boolean screenOn = pm.isScreenOn();
        if (!screenOn) {
            // 获取PowerManager.WakeLock对象,后面的参数|表示同时传入两个值,最后的是LogCat里用的Tag
            PowerManager.WakeLock wl = pm.newWakeLock(
                    PowerManager.ACQUIRE_CAUSES_WAKEUP |
                            PowerManager.SCREEN_BRIGHT_WAKE_LOCK, "bright");
            wl.acquire(10000); // 点亮屏幕
            wl.release(); // 释放
        }
        // 屏幕解锁
        KeyguardManager keyguardManager = (KeyguardManager) instance.getContext()
                .getSystemService(KEYGUARD_SERVICE);
        KeyguardManager.KeyguardLock keyguardLock = keyguardManager.newKeyguardLock("unLock");
        // 屏幕锁定
        keyguardLock.reenableKeyguard();
        keyguardLock.disableKeyguard(); // 解锁
    }

    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;  
                }  
            }  
            return false;  
        } 
     
    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }
    
    public static String getLocalIpAddress() {
        return hostIPAdress;
    }
    
    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
  
    public static final boolean isApkInstalled(Context context, String packageName) {
        try {
                context.getPackageManager().getApplicationInfo(packageName, PackageManager.GET_UNINSTALLED_PACKAGES);
                return true;
            } catch (NameNotFoundException e) {
                return false;
        }
    }
    
    public static byte[] bmpToByteArray(final Bitmap bmp,
            final boolean needRecycle) {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        bmp.compress(CompressFormat.PNG, 100, output);
        if (needRecycle) {
            bmp.recycle();
        }
        byte[] result = output.toByteArray();
        try {
            output.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public static void saveImageToGallery(Context context, Bitmap bmp) {
        // 首先保存图片
        File appDir = new File(Environment.getExternalStorageDirectory(), "Boohee");
        if (!appDir.exists()) {
            appDir.mkdir();
        }
        String fileName = System.currentTimeMillis() + ".jpg";
        File file = new File(appDir, fileName);
        try {
            FileOutputStream fos = new FileOutputStream(file);
            bmp.compress(CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 其次把文件插入到系统图库
        try {
            MediaStore.Images.Media.insertImage(context.getContentResolver(),
                    file.getAbsolutePath(), fileName, null);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        // 最后通知图库更新
        context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + fileName)));
    }

    public static String buildTransaction(final String type) {
        return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
    }
    
        public static String intToIp(int ip) {
        return (ip & 0xFF) + "." + ((ip >> 8) & 0xFF) + "."
                + ((ip >> 16) & 0xFF) + "." + ((ip >> 24) & 0xFF);
    }
     
    public static String getIP() {
        // 获取wifi服务
        WifiManager wifiManager = (WifiManager) AppActivity.instance.getSystemService(Context.WIFI_SERVICE);
        // 判断wifi是否开启
        if (wifiManager.isWifiEnabled()) {
//          wifiManager.setWifiEnabled(true);
            WifiInfo wifiInfo = wifiManager.getConnectionInfo();
            int ipAddress = wifiInfo.getIpAddress();
            return intToIp(ipAddress);
        }
        try { 
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) { 
                NetworkInterface intf = en.nextElement(); 
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) { 
                    InetAddress inetAddress = enumIpAddr.nextElement(); 
                    if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) { 
                        // if (!inetAddress.isLoopbackAddress() && inetAddress 
                        // instanceof Inet6Address) { 
                        return inetAddress.getHostAddress().toString(); 
                    } 
                } 
            } 
        } catch (Exception e) { 
        }
        
        return "127.0.0.1";
    }
    
    public static void instanllAPP(String filepath) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.setAction(android.content.Intent.ACTION_VIEW);
        File file = new File(filepath);
        intent.setDataAndType(Uri.fromFile(file),
                "application/vnd.android.package-archive");
        instance.startActivity(intent);
    }

    //启动一个app
    public void startAPP(){
        try{
            Intent intent = this.getPackageManager().getLaunchIntentForPackage(getPackageName());
            // startActivity(intent);
            startActivityForResult(intent, 101);
        }catch(Exception e){
            Toast.makeText(this, "没有安装", Toast.LENGTH_LONG).show();
        }
    }
    // restart
    public static void restartApplication() {    
            final Intent intent = instance.getPackageManager().getLaunchIntentForPackage(instance.getPackageName());    
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);    
            instance.startActivity(intent);    
    }  

    public static String getDeviceId() {
        TelephonyManager tm = (TelephonyManager) instance.getSystemService(Context.TELEPHONY_SERVICE);
        return tm.getDeviceId();

    }

    //电池电量
    public static float getDeviceBatteryLevel() {
        return batteryLevel;
    }
    
    //wifi signal
    public static void setWifiSignal(){
        wifiIntentFilter = new IntentFilter();
        wifiIntentFilter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
        wifiIntentReceiver = new BroadcastReceiver(){
            @Override
            public void onReceive(Context context, Intent intent) {
                // TODO Auto-generated method stub
                int wifi_state = intent.getIntExtra("wifi_state", 0);
                  wifiSignalState = wifi_state;
                float level = Math.abs(((WifiManager)AppActivity.instance.getSystemService(WIFI_SERVICE)).getConnectionInfo().getRssi() + 100);
                // Log.v("info", "setWifiSignal"+level);
                wifiSignalLevel = level/100;
//              switch (wifi_state) {
//              case WifiManager.WIFI_STATE_DISABLING:
//                  break;
//              case WifiManager.WIFI_STATE_DISABLED:
//                  break;
//              case WifiManager.WIFI_STATE_ENABLING:
//                  break;
//              case WifiManager.WIFI_STATE_ENABLED:
//                  break;
//              case WifiManager.WIFI_STATE_UNKNOWN:
//                  break;
//              default:
//                  break;
//              }
            }
        };
        AppActivity.instance.registerReceiver(wifiIntentReceiver, wifiIntentFilter);  
    }
    
    public static float getDeviceSignalLevel() {
        return wifiSignalLevel;
    }

    public static int getDeviceSignalState() {
        return wifiSignalState;
    }
    
    static public void setMobileSignal(){
        telephoneManager = (TelephonyManager) AppActivity.instance.getSystemService(Context.TELEPHONY_SERVICE);
        final int type = telephoneManager.getNetworkType();  
        mobileSignalState = type;
        phoneStateListener = new PhoneStateListener() {
            @Override  
            public void onSignalStrengthsChanged(SignalStrength signalStrength) {  
                // TODO Auto-generated method stub  
                super.onSignalStrengthsChanged(signalStrength);  
                mobileSignalLevel = signalStrength.getGsmSignalStrength()/100;
                // --
                String _strSubTypeName = "TD-SCDMA";
                switch (type) {
                case TelephonyManager.NETWORK_TYPE_GPRS:
                case TelephonyManager.NETWORK_TYPE_EDGE:
                case TelephonyManager.NETWORK_TYPE_CDMA:
                case TelephonyManager.NETWORK_TYPE_1xRTT:
                case TelephonyManager.NETWORK_TYPE_IDEN: //api<8 : replace by 11
                    //strNetworkType = "2G";
                    mobileSignalState = 2;
                    break;
                case TelephonyManager.NETWORK_TYPE_UMTS:
                case TelephonyManager.NETWORK_TYPE_EVDO_0:
                case TelephonyManager.NETWORK_TYPE_EVDO_A:
                case TelephonyManager.NETWORK_TYPE_HSDPA:
                case TelephonyManager.NETWORK_TYPE_HSUPA:
                case TelephonyManager.NETWORK_TYPE_HSPA:
                case TelephonyManager.NETWORK_TYPE_EVDO_B: //api<9 : replace by 14
                case TelephonyManager.NETWORK_TYPE_EHRPD:  //api<11 : replace by 12
                case TelephonyManager.NETWORK_TYPE_HSPAP:  //api<13 : replace by 15
                    //strNetworkType = "3G";
                    mobileSignalState = 3;
                    break;
                case TelephonyManager.NETWORK_TYPE_LTE:    //api<11 : replace by 13
                    //strNetworkType = "4G";
                    break;
                default:
                    // http://baike.baidu.com/item/TD-SCDMA 中国移动 联通 电信 三种3G制式
                    if (_strSubTypeName.equalsIgnoreCase("TD-SCDMA") || _strSubTypeName.equalsIgnoreCase("WCDMA") || _strSubTypeName.equalsIgnoreCase("CDMA2000")) 
                    {
                        //strNetworkType = "3G";
                        mobileSignalState = 3;
                    }
                    else
                    {
                        //strNetworkType = _strSubTypeName;
                        mobileSignalState = 0;
                    }
                    
                    break;
                }
            }  
        };
        telephoneManager.listen(phoneStateListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);  
    }
    
    public static float getDeviceMobileLevel() {
        return mobileSignalLevel;
    }

    public static int getDeviceMobileState() {
        return mobileSignalState;
    }

    public static void copyClipboard(final String str) {
        Runnable runnable = new Runnable() {
          public void run() {
            ClipboardManager mClipboardManager = (ClipboardManager)instance.getSystemService(CLIPBOARD_SERVICE);
            mClipboardManager.setText(str);
            }
        };
        instance.runOnUiThread(runnable);
    }

    public static String tempStr;  
    public static String getClipBoardContent()  
    {  
      instance.runOnUiThread(new Runnable() {  
            
          @Override  
          public void run() {  
              // TODO Auto-generated method stub  
              ClipboardManager clipboardManager=(ClipboardManager)instance.getSystemService(Context.CLIPBOARD_SERVICE);  
              if(clipboardManager==null)  
              {  
                  // Log.i("cp", "clipboardManager==null");  
                    
              }  
              if(clipboardManager.getText()!=null)  
              {  
                  tempStr=clipboardManager.getText().toString();  
                  AppActivity.onClipboard(tempStr);
              }  
          }  
      });  
      return tempStr;  
    } 
    public static native void onClipboard(String content);

    public static double getDistance(double lat1, double lon1, double lat2, double lon2) {  
        float[] results=new float[1];  
        try{
        Location.distanceBetween(lat1, lon1, lat2, lon2, results);  
        }catch(Exception e){
            e.printStackTrace();
        }
        return results[0];  
    }

    public void onHideSoftButton() {
        View decorView = getWindow().getDecorView();    
        int uiOptions = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        |View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        |View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
        |View.SYSTEM_UI_FLAG_HIDE_NAVIGATION  //隐藏导航栏                   
        |View.SYSTEM_UI_FLAG_FULLSCREEN       //全屏，状态栏和导航栏不显示 
        |View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;    
        decorView.setSystemUiVisibility(uiOptions);
    }

    public static boolean isAndroidSimulator()
    {
        String serial = android.os.Build.SERIAL;
        boolean b_simulator = (serial == null);
        return b_simulator;
    }

    //------------THIRD-------------------------------------------------------------------
    //amap
    private LocationManagerProxy aMapManager;
    private void startAmap() {
    aMapManager = LocationManagerProxy.getInstance(this);
    /*
     * mAMapLocManager.setGpsEnable(false);
     * 1.0.2版本新增方法，设置true表示混合定位中包含gps定位，false表示纯网络定位，默认是true Location
     * API定位采用GPS和网络混合定位方式
     * ，第一个参数是定位provider，第二个参数时间最短是2000毫秒，第三个参数距离间隔单位是米，第四个参数是定位监听者
     */
    aMapManager.requestLocationUpdates(LocationProviderProxy.AMapNetwork, 2000, 10, mAMapLocationListener);
    }

    private void stopAmap() {
        if (aMapManager != null) {
          aMapManager.removeUpdates(mAMapLocationListener);
          aMapManager.destory();
        }
        aMapManager = null;
    }
    private AMapLocationListener mAMapLocationListener = new AMapLocationListener() {
        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
        }

        @Override
        public void onProviderEnabled(String provider) {
        }

        @Override
        public void onProviderDisabled(String provider) {
        }

        @Override
        public void onLocationChanged(Location location) {
        }

        @Override
        public void onLocationChanged(AMapLocation location) {
          if (location != null) {
            mMapLoopTimes += 1;
            if (mMapLoopTimes % 400 == 0) { //5s 大概
                mMapLoopTimes = 0;
                return ;
            }
            Double geoLat = location.getLatitude();
            Double geoLng = location.getLongitude();
            String cityCode = "";
            String desc = "";
            Bundle locBundle = location.getExtras();
            if (locBundle != null) {
              cityCode = locBundle.getString("citycode");
              desc = locBundle.getString("desc");
            }
            instance.setCurrentLocationForAndroid(geoLat, geoLng);
            
            // String str = ("定位成功:(" + geoLng + "," + geoLat + ")"
            //     + "\n精    度    :" + location.getAccuracy() + "米"
            //     + "\n定位方式:" + location.getProvider() + "\n定位时间:"
            //     + new Date(location.getTime()).toLocaleString() + "\n城市编码:"
            //     + cityCode + "\n位置描述:" + desc + "\n省:"
            //     + location.getProvince() + "\n市:" + location.getCity()
            //     + "\n区(县):" + location.getDistrict() + "\n区域编码:" + location
            //     .getAdCode());
            if (desc == null) desc = "";
            instance.setCurrentLocationInfoForAndroid(desc);
            // stopAmap();
            // Toast.makeText(instance, "高德定位"+desc, 1).show(); 
          }
        }
    };
    // weixin
    public static void registerWeixin(String appID){  
        mWeiXinApi = WXAPIFactory.createWXAPI(instance, appID, true);
        mWeiXinAppid=appID;
        if(mWeiXinApi != null){  
           // 将应用注册到微信  
            // Log.i("info", "registerWeixin");
            mWeiXinApi.registerApp(appID);  
        }  
    }
    public static void sendAuthRequest(){
        if(isApkInstalled(instance, "com.tencent.mm")){
            final SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo";
            req.state = "wechat_sdk_demo_test";
            // Log.i("info", "sendAuthRequest");
            mWeiXinApi.sendReq(req);
            
        }else{
            Toast.makeText(instance, "亲，请在你的设备上安装微信", 1).show(); 
        }
    }
    public static void shareWebToWeixin(String title, String description, String image,String webpageUrl,int type){
        if (-1 == type) {
            Bitmap bmp = BitmapFactory.decodeFile(image);
            saveImageToGallery(instance.getApplicationContext(), bmp);
            // Toast.makeText(instance, "图片已经存入相册", Toast.LENGTH_SHORT).show();
        }else{
            //
            if(mWeiXinApi.openWXApp())
            {
                WXWebpageObject webpage = new WXWebpageObject();
                webpage.webpageUrl = webpageUrl;
                WXMediaMessage msg = new WXMediaMessage(webpage);
                msg.title = title;
                msg.description = description;
         
                Bitmap thumb = BitmapFactory.decodeResource(instance.getResources(), R.drawable.icon);
                int WX_THUMB_SIZE = 72;
                Bitmap thumbBmp = Bitmap.createScaledBitmap(thumb, WX_THUMB_SIZE, WX_THUMB_SIZE, true);
                //thumb.recycle();
                msg.thumbData = bmpToByteArray(thumbBmp, true);
               
                SendMessageToWX.Req req = new SendMessageToWX.Req();
                req.transaction = String.valueOf(System.currentTimeMillis());
                req.message = msg;
                req.scene = type == 0 ? SendMessageToWX.Req.WXSceneSession: SendMessageToWX.Req.WXSceneTimeline;
                mWeiXinApi.sendReq(req);
            }
            else
            {
                 Toast.makeText(instance, "未安装微信", Toast.LENGTH_SHORT).show();
            }
        }
    }
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
//              Bitmap thumbBmp1 = BitmapFactory.decodeFile(thumbImagepath);
//              msg.thumbData = bmpToByteArray(thumbBmp, true);
            Bitmap thumbBmp;
            if (bhengping) {
             thumbBmp = Bitmap.createScaledBitmap(bmp, 128, 72, true);
            }else{
              thumbBmp = Bitmap.createScaledBitmap(bmp, 72, 128, true);
            } 
            //bmp.recycle();
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
    public static void jumpToWeixinPay(String appId,String partnerId,String prepayId,String package1,String sign,String nonceStr,int timeStamp){
        
        PayReq req = new PayReq();
        req.appId           = appId;
        req.partnerId       = partnerId;
        req.prepayId        = prepayId;
        req.nonceStr        = nonceStr;
        req.timeStamp       = String.valueOf(timeStamp);
        req.packageValue    = package1;
        req.sign            = sign;
//      req.extData         = "app data"; // optional
        mWeiXinApi.sendReq(req);
    }

    // yixin ...
    public static boolean isYXAppInstalled(){
        return mYiXinApi.isYXAppInstalled();
    }
    public static void registerYiXin(String s_appID){  
         // yixin
        instance.mYiXinAppid = s_appID;
        mYiXinApi = YXAPIFactory.createYXAPI(instance, s_appID);
        mYiXinApi.registerApp();
    }
    public static void registerYiXinID(String s_appID, String s_appSecret){  
         // yixin
        instance.mYiXinAppid = s_appID;
        mYiXinApi = YXAPIFactory.createYXAPI(instance, s_appID);
        mYiXinApi.registerApp();
    }
    public static boolean sendAuthRequestToYiXin()
    {
        if (mYiXinApi.isSupportOauth()) {
          SendAuthToYX.Req req = new SendAuthToYX.Req();
          req.state = "asdfsdaf";
          req.transaction = String.valueOf(System.currentTimeMillis());
          mYiXinApi.sendRequest(req);
        }
        return false;
    }
    public static void shareImageToYiXin(String thumbImagepath, String imagepath, int type) {
        boolean bhengping = (type / 2 == 0);
        // ...
        Bitmap bmp = BitmapFactory.decodeFile(imagepath);
        Bitmap thumbBmp;
        Bitmap bigbBmp;
        if (bhengping) {
           thumbBmp = Bitmap.createScaledBitmap(bmp, 128, 72, true);
           bigbBmp = Bitmap.createScaledBitmap(bmp, 960, 540, true);
        }else{
           thumbBmp = Bitmap.createScaledBitmap(bmp, 72, 128, true);
           bigbBmp = Bitmap.createScaledBitmap(bmp, 540, 960, true);
         }
        bmp.recycle();

        YXImageMessageData imgObj = new YXImageMessageData(bigbBmp);
        YXMessage msg = new YXMessage();
        msg.messageData = imgObj;
        msg.thumbData = BitmapUtil.bmpToByteArray(thumbBmp, true);

        SendMessageToYX.Req req = new SendMessageToYX.Req();
        req.transaction = buildTransaction("img");
        req.message = msg;
        if (0 == type%2) { //YXCollect  YXSceneSession  YXSceneTimeline
          req.scene = SendMessageToYX.Req.YXSceneSession;
        }else {
          req.scene = SendMessageToYX.Req.YXSceneTimeline;
        }
        mYiXinApi.sendRequest(req);
    }
    public static void shareWebToYiXin(String title, String description, String image, String webpageUrl, int type) {
        // chushi
        YXWebPageMessageData webpage = new YXWebPageMessageData();
        webpage.webPageUrl = webpageUrl;
        YXMessage msg = new YXMessage(webpage);
        // msg.title = "WebPage Title WebPage Title WebPage Title WebPage Title WebPage Title WebPage Title WebPage Title WebPage Title WebPage Title Very Long Very Long Very Long Very Long Very Long Very Long Very Long Very Long Very Long Very Long";
        msg.title = title;
        // msg.description = "WebPage Description WebPage Description WebPage Description WebPage Description WebPage Description WebPage Description WebPage Description WebPage Description WebPage Description Very Long Very Long Very Long Very Long Very Long Very Long Very Long";
        msg.description = description;
        // Bitmap thumb = BitmapFactory.decodeResource(getResources(), R.drawable.test);
        // msg.thumbData = BitmapUtil.bmpToByteArray(thumb, true);
        Bitmap thumb = BitmapFactory.decodeResource(instance.getResources(), R.drawable.icon);
        int WX_THUMB_SIZE = 72;
        Bitmap thumbBmp = Bitmap.createScaledBitmap(thumb, WX_THUMB_SIZE, WX_THUMB_SIZE, true);
        //thumb.recycle();
        msg.thumbData = BitmapUtil.bmpToByteArray(thumbBmp, true);

        // 
        SendMessageToYX.Req req = new SendMessageToYX.Req();
        req.transaction = buildTransaction("webpage");
        req.message = msg;
        if (0 == type%2) {
          req.scene = SendMessageToYX.Req.YXSceneSession;
        }else {
          req.scene = SendMessageToYX.Req.YXSceneTimeline;
        }
        mYiXinApi.sendRequest(req);
    }
    public static void shareTextToYiXin(String text, int type) {
        // 初始化一个YXTextObject对象
        YXTextMessageData textObj = new YXTextMessageData();
        textObj.text = text;

        // 用YXTextObject对象初始化一个YXMessage对象
        YXMessage msg = new YXMessage();
        msg.messageData = textObj;
        // 发送文本类型的消息时，title字段不起作用
        // msg.title = "title is ignored";
        msg.description = text;

        // 构造一个Req对象
        SendMessageToYX.Req req = new SendMessageToYX.Req();
        // transaction字段用于唯一标识一个请求
        req.transaction = buildTransaction("text"); 
        req.message = msg;
        // leixing
        if (0 == type%2) {
          req.scene = SendMessageToYX.Req.YXSceneSession;
        }else {
          req.scene = SendMessageToYX.Req.YXSceneTimeline;
        }

        // 调用api接口发送数据到易信
        mYiXinApi.sendRequest(req);
    }

    // dingtalk
    public static boolean isInstallDingTalk() {
        return iddShareApi.isDDAppInstalled();
    }
    public static boolean isSupportDingTalk() {
        return iddShareApi.isDDSupportAPI();
    }
    public static boolean registerAppDingTalk(String appid){
      try {
          //activity的export为true，try起来，防止第三方拒绝服务攻击
          instance.mDingTalkAppid = appid;
          iddShareApi = DDShareApiFactory.createDDShareApi(instance, appid, true);          
          // if(iddShareApi != null){  
          //   api.registerApp(appid);
          // }  
      } catch (Exception e) {
          e.printStackTrace();
          // Log.d("lzc" , "e===========>"+e.toString());
      }
      return true;
    }
    public static boolean sendTextDingTalk(String text, int n_type) {
      //初始化一个DDTextMessage对象
      DDTextMessage textObject = new DDTextMessage();
      textObject.mText = text;
      //用DDTextMessage对象初始化一个DDMediaMessage对象
      DDMediaMessage mediaMessage = new DDMediaMessage();
      mediaMessage.mMediaObject = textObject;
      //构造一个Req
      SendMessageToDD.Req req = new SendMessageToDD.Req();
      req.mMediaMessage = mediaMessage;
      //调用api接口发送消息到钉钉
      return iddShareApi.sendReq(req);
    }
    public static boolean sendImageDingTalk(String path, int n_type) {
        Bitmap bmp = BitmapFactory.decodeFile(path);
        //初始化一个DDImageMessage
        DDImageMessage imageObject = new DDImageMessage(bmp);
        if (bmp != null)
            bmp.recycle();

        //构造一个DDMediaMessage对象
        DDMediaMessage mediaMessage = new DDMediaMessage();
        mediaMessage.mMediaObject = imageObject;

        //构造一个Req
        SendMessageToDD.Req req = new SendMessageToDD.Req();
        req.mMediaMessage = mediaMessage;
        //        req.transaction = buildTransaction("image");
        //调用api接口发送消息到支付宝
        return iddShareApi.sendReq(req);
    }
    public static boolean sendWebDingTalk(String surl, String stitle, String sthumimg, String scontent, int n_type) {
        //初始化一个DDWebpageMessage并填充网页链接地址
        DDWebpageMessage webPageObject = new DDWebpageMessage();
        webPageObject.mUrl = surl;
        //构造一个DDMediaMessage对象
        DDMediaMessage webMessage = new DDMediaMessage();
        webMessage.mMediaObject = webPageObject;
        //填充网页分享必需参数，开发者需按照自己的数据进行填充
        webMessage.mTitle = stitle;
        webMessage.mContent = scontent;
        // webMessage.mThumbUrl = "https://t.alipayobjects.com/images/rmsweb/T1vs0gXXhlXXXXXXXX.jpg";
        // 网页分享的缩略图也可以使用bitmap形式传输
        Bitmap bmp = BitmapFactory.decodeFile(sthumimg);
        webMessage.setThumbImage(bmp);
        //构造一个Req
        SendMessageToDD.Req webReq = new SendMessageToDD.Req();
        webReq.mMediaMessage = webMessage;
        //        webReq.transaction = buildTransaction("webpage");
        //调用api接口发送消息到支付宝
        return iddShareApi.sendReq(webReq);
    }
    
    /**
     * 截取当前屏幕图片，注意，只适用于常规Android activity截屏
     * @return
     */
    private Bitmap captureScreen() {
        View cv = getWindow().getDecorView();
        cv.setDrawingCacheEnabled(true);
        cv.buildDrawingCache();
        Bitmap bmp = cv.getDrawingCache();
        if (bmp == null) {
            return null;
        }
        bmp.setHasAlpha(false);
        bmp.prepareToDraw();
        return bmp;
    }

    // chuiniu
    public static SdkBuilder sdkBuilder = new SdkImplBuilder();
    public static SdkDirector sdkDirector;
    public static String cnappid;
    public static String cnappsecret;
    public static boolean isInstallChuiNiu() {
        return sdkDirector.isInstallChuiNiu(instance);
    }
    public static boolean registerAppChuiNiu(String appid, String appsecret){
        sdkDirector = SdkDirector.getInstance(instance, sdkBuilder);
        cnappid = appid;
        cnappsecret = appsecret;
        return true;
    }
    public static void sendWebToChuiNiu(String stitle, String scontent, String sthumimg, String surl, int n_type) {
        // Bitmap bitmap = BitmapFactory.decodeFile(sthumimg);
        // if(bitmap == null) bitmap = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);

        // Uri uri = Uri.parse(surl);  
        // String title = uri.getQueryParameter("title");
        // String game = uri.getQueryParameter("game");
        // String room = uri.getQueryParameter("room");
        // //初始化一个SGImageObject对象，设置所分享的图片内容
        // SGGameObject gameObject = new SGGameObject(bitmap);
        // gameObject.roomId = game + "_" + room;
        // gameObject.roomToken = surl; //可以自定义邀请应用的下载链接，也可以不填，不填会默认使用应用申请 appid 时填写的链接 gameObject.androidDownloadUrl = "http://www.updrips.com/index.html"; gameObject.iOSDownloadUrl = "http://www.updrips.com/index.html";
        // // gameObject.androidDownloadUrl = "https://www.baidu.com";
        // // gameObject.iOSDownloadUrl = "https://www.baidu.com";
        // // gameObject.imagePath = "http://merchant.xianliao.updrips.com/views/application/edit-app.html?id=615";

        // Bitmap bitmap2 = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);
        // //用 SGGameObject 对象初始化一个 SGMediaMessage 对象
        // SGMediaMessage msg = new SGMediaMessage(); 
        // msg.mediaObject = gameObject;
        // msg.title = stitle;
        // msg.description = scontent;
        // msg.setThumbImage(bitmap2);

        // //构造一个 Req
        // SendMessageToSG.Req req = new SendMessageToSG.Req(); 
        // req.transaction = SGConstants.T_GAME;
        // req.mediaMessage = msg;
        // req.scene = SendMessageToSG.Req.SGSceneSession; //代表分享到会话列表 
        // //调用 api 接口发送数据到闲聊
        // mXianLiaoApi.sendReq(req);

        int type = SdkDirector.LINK;
        String linkUrl = surl;//(跳转的链接地址)
        String thumb = sthumimg;//（图片logo（网络地址）如没有传””）
        String content = scontent;//要分享的内容
        String title = stitle;//要分享的标题 
        String backinfo = "";//（暂无用）
        String cnextra = "";//（扩展字段目前传””）
        sdkDirector.setAppId(cnappid).setAppSecret(cnappsecret);
        sdkDirector.shareLink(instance, type, linkUrl, thumb, content, title, backinfo, cnextra); 
        sdkDirector.setShareCallBack(new SdkDirector.ShareCallBack() {
            @Override
            public void myShareBack(String status, String message) {
                //message: 0为成功 其它值为失败；
                //status: onSuccess 成功，onFailure 失败
               Toast.makeText(instance, status, Toast.LENGTH_SHORT).show();
                Log.v("heheda===============", status + " " + message );
                int n_status = 1;
                if (status == "onSuccess") n_status = 0;
                AppActivity.onResp("chuiniu_share", "", "", "", 1, n_status);
            }
        });
    }
    public static void sendImageToChuiNiu(String thumpath, String path, int n_type) {
        // boolean bhengping = (n_type / 2 == 0);

        // // Log.v("heheda", "sendImagssssseToXianLiao" + path);
        // Bitmap bitmap = BitmapFactory.decodeFile(path);
        // // if (bitmap == null) bitmap = instance.captureScreen(); 
        // if(bitmap == null) bitmap = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);

        // //初始化一个SGImageObject对象，设置所分享的图片内容
        // SGImageObject imageObject = new SGImageObject(bitmap);

        // //用SGImageObject对象初始化一个SGMediaMessage对象
        // SGMediaMessage msg = new SGMediaMessage();
        // msg.mediaObject = imageObject;

        // //构造一个Req
        // SendMessageToSG.Req req = new SendMessageToSG.Req();
        // req.transaction = SGConstants.T_IMAGE;
        // req.mediaMessage = msg;
        // req.scene = SendMessageToSG.Req.SGSceneSession; //代表分享到会话列表

        // //调用api接口发送数据到闲聊
        // mXianLiaoApi.sendReq(req);
        int type = SdkDirector.IMAGE;
        String imgUrl = "";// 需要先上传图片回调地址返给SDK
        String content = "";//参数说明同上  
        String title = "吹牛";//参数说明同上  
        File file = new File(thumpath);//图片file地址
        String extra = "";//扩展字段当前可传空
        // // 传图片网络地址
        // sdkDirector.shareImage(instance, type, imgUrl, content, title); 
        // 传文件
        sdkDirector.setAppId(cnappid).setAppSecret(cnappsecret);
        sdkDirector.shareImage(instance, type, file, content, title, extra);
        sdkDirector.setShareCallBack(new SdkDirector.ShareCallBack() {
            @Override
            public void myShareBack(String status, String message) {
                //message: 0为成功 其它值为失败；
                //status: onSuccess 成功，onFailure 失败
               Toast.makeText(instance, status, Toast.LENGTH_SHORT).show();
                Log.v("heheda===============", status + " " + message );
                int n_status = 1;
                if (status == "onSuccess") n_status = 0;
                AppActivity.onResp("chuiniu_share", "", "", "", 1, n_status);
            }
        });
    }
    public static boolean sendAuthRequestToChuiNiu(){
        Log.v("heheda===============", "sendAuthRequestToChuiNiu"+"cnappid"+cnappid+"cnappsecret"+cnappsecret);
        sdkDirector.setAppId(cnappid).setAppSecret(cnappsecret);
        sdkDirector.cnAuthLogin(instance).setMyCallBack(new SdkDirector.MyCallBack(){
            @Override
            public void myBack(String accessToken, String openId, String refreshToken) {
                Toast.makeText(instance, openId, Toast.LENGTH_SHORT).show();
                //accessToken和openId去请求用户信息
                Log.v("heheda===============myBack", accessToken + " " + openId + " " + refreshToken);
                AppActivity.onResp("chuiniu_auth", openId, accessToken, "", 0, 0);
            }
        });
        return true;
    }

    // xianliao
    public static boolean isInstallXianLiao() {
        return mXianLiaoApi.isSGAppInstalled();
    }
    public static boolean registerAppXianLiao(String appid){
        mXianLiaoAppid = appid;
        mXianLiaoApi = SGAPIFactory.createSGAPI(instance, appid);
        return true;
    }
    public static void sendTextToXianLiao(String textContent, int n_type) {
        // String textContent = "这是测试数据，测试数据";
        //初始化一个SGTextObject对象，填写分享的文本内容
        SGTextObject textObject = new SGTextObject();
        textObject.text = textContent;

        //用SGTextObject对象初始化一个SGMediaMessage对象
        SGMediaMessage msg = new SGMediaMessage();
        msg.mediaObject = textObject;
//        msg.title = "titleXXX";

        //构造一个Req
        SendMessageToSG.Req req = new SendMessageToSG.Req();
        req.transaction = SGConstants.T_TEXT;
        req.mediaMessage = msg;
        req.scene = SendMessageToSG.Req.SGSceneSession; //代表分享到会话列表

        //调用api接口发送数据到闲聊
        mXianLiaoApi.sendReq(req);
    }
    public static void sendImageToXianLiao(String thumpath, String path, int n_type) {
        boolean bhengping = (n_type / 2 == 0);

        // Log.v("heheda", "sendImagssssseToXianLiao" + path);
        Bitmap bitmap = BitmapFactory.decodeFile(path);
        // if (bitmap == null) bitmap = instance.captureScreen(); 
        if(bitmap == null) bitmap = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);

        //初始化一个SGImageObject对象，设置所分享的图片内容
        SGImageObject imageObject = new SGImageObject(bitmap);

        //用SGImageObject对象初始化一个SGMediaMessage对象
        SGMediaMessage msg = new SGMediaMessage();
        msg.mediaObject = imageObject;

        //构造一个Req
        SendMessageToSG.Req req = new SendMessageToSG.Req();
        req.transaction = SGConstants.T_IMAGE;
        req.mediaMessage = msg;
        req.scene = SendMessageToSG.Req.SGSceneSession; //代表分享到会话列表

        //调用api接口发送数据到闲聊
        mXianLiaoApi.sendReq(req);
    }
    public static void sendWebToXianLiao(String stitle, String scontent, String sthumimg, String surl, int n_type) {
        Bitmap bitmap = BitmapFactory.decodeFile(sthumimg);
        if(bitmap == null) bitmap = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);

        Uri uri = Uri.parse(surl);  
        String title = uri.getQueryParameter("title");
        String game = uri.getQueryParameter("game");
        String room = uri.getQueryParameter("room");
        //初始化一个SGImageObject对象，设置所分享的图片内容
        SGGameObject gameObject = new SGGameObject(bitmap);
        gameObject.roomId = game + "_" + room;
        gameObject.roomToken = surl; //可以自定义邀请应用的下载链接，也可以不填，不填会默认使用应用申请 appid 时填写的链接 gameObject.androidDownloadUrl = "http://www.updrips.com/index.html"; gameObject.iOSDownloadUrl = "http://www.updrips.com/index.html";
        // gameObject.androidDownloadUrl = "https://www.baidu.com";
        // gameObject.iOSDownloadUrl = "https://www.baidu.com";
        // gameObject.imagePath = "http://merchant.xianliao.updrips.com/views/application/edit-app.html?id=615";

        Bitmap bitmap2 = BitmapFactory.decodeResource(instance.getResources(), R.drawable.xianliao);
        //用 SGGameObject 对象初始化一个 SGMediaMessage 对象
        SGMediaMessage msg = new SGMediaMessage(); 
        msg.mediaObject = gameObject;
        msg.title = stitle;
        msg.description = scontent;
        msg.setThumbImage(bitmap2);

        //构造一个 Req
        SendMessageToSG.Req req = new SendMessageToSG.Req(); 
        req.transaction = SGConstants.T_GAME;
        req.mediaMessage = msg;
        req.scene = SendMessageToSG.Req.SGSceneSession; //代表分享到会话列表 
        //调用 api 接口发送数据到闲聊
        mXianLiaoApi.sendReq(req);
    }
    public static boolean sendAuthRequestToXianLiao()
    {
        org.xianliao.im.sdk.modelmsg.SendAuth.Req req = new org.xianliao.im.sdk.modelmsg.SendAuth.Req();
        req.state = "none";
        return mXianLiaoApi.sendReq(req);
    }
    // resp ---------
    public static native void onRespJNI(String code, int n_type);
    public static native void onRespShareJNI(int code, int n_type);
    public static native void onPayResult(int code);
    public static native void setCurrentLocationForAndroid(double lati, double longti);
    public static native void setCurrentLocationInfoForAndroid(String str);
    public static native void onWechatJoinRoom(String game, String room);
    public static native void onWechatJoinExit();
    public static native void onRespDingTalk(String code);
    public static native void onRespShareDingTalk(int errorcode);
    public static native void onResp(String type, String status, String value, String extra, int n_type, int n_code);
}













