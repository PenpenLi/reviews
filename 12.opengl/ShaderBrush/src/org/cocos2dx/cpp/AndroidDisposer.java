package org.cocos2dx.cpp;

import java.io.ByteArrayOutputStream;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.MediaStore.Audio;
import android.provider.Settings.Global;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.media.MediaPlayer;
import android.media.MediaRecorder;

public class AndroidDisposer{
	
	public static final int 	PHOTOHRAPH = 1;		// 鎷嶇収
	public static final int 	PHOTOZOOM = 2; 		// 缂╂斁
	public static final int 	PHOTORESOULT = 3;	// 缁撴灉
	public static final int 	AUDIOLOCAL = 4;		// 鏈湴闊充箰
	public static final String  intentTypeImage = "image/*";

    private static AndroidDisposer instance = null;
    private static Activity    activity = null;
    private static TelephonyManager telephoneManager = null;
    private static PhoneStateListener phoneStateListener = null;
    private static MediaRecorder mediaRecorder; 
    //private static WifiManager wifi_service = null; 
    //private static WifiInfo wifiInfo = null;
    private static IntentFilter wifiIntentFilter = null; 
    private static BroadcastReceiver wifiIntentReceiver = null;
    
    public static Uri uritempFile;
    public static String  imagepath;
    public static String strFileStorage = Environment.getExternalStorageDirectory().getPath();
    //private static String strFileDir = activity.getFilesDir().getPath();
    public static String strFileRecord;
    
    public static native void ccpCallback(String path);
    public static void cppCallbackWithPath(final String path)
    {
        Cocos2dxGLSurfaceView.getInstance().queueEvent(new Runnable() {
            @Override
              public void run() {
            	ccpCallback(path);
              }
            });
    }
    
    public static AndroidDisposer getInstance(){
    	if(instance == null){
    		instance = new AndroidDisposer();
    	}
    	return instance;
    }
    
    public void init(Activity activity){
    	AndroidDisposer.activity = activity;
    	//setSignalStrength();
    	//setWifiRSSI();
    	mediaRecorder = new MediaRecorder();
    }

    public static void onPause(){
    	//telephoneManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE);  
    	//activity.unregisterReceiver(wifiIntentReceiver);  
    }
    
    public static void onResume(){
    	//telephoneManager.listen(phoneStateListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS); 
    	//activity.registerReceiver(wifiIntentReceiver, wifiIntentFilter);  
    }
    
	static public void openPhoto(){
		Intent intent = new Intent(Intent.ACTION_PICK, null);
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, intentTypeImage);
		activity.startActivityForResult(intent, PHOTOZOOM);
	}
	 
	static public void openCamera(){
    	Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    	intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(strFileStorage +"/@cc_cameraCache.jpg")));
        intent.putExtra("android.intent.extra.screenOrientation", false);
    	activity.startActivityForResult(intent, PHOTOHRAPH);
    }
	
    static public void openAudio(){
		Intent intent=new Intent(Intent.ACTION_PICK,android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI); 
		activity.startActivityForResult(intent, AUDIOLOCAL);
    }
    
	public void onActivityResult(int requestCode, int resultCode, Intent data){
		//Log.i("info", "fgghdf=="+requestCode+resultCode+data);
		Log.v("MyService", "onActivityResult"+requestCode+resultCode+data);
		if (resultCode == 0)
            return;
        
        if (requestCode == PHOTOHRAPH) {
        	File picture = new File(strFileStorage +"/@cc_cameraCache.jpg");
            startPhotoZoom(Uri.fromFile(picture));
        }
 
        if (data != null && requestCode == PHOTOZOOM) {
            startPhotoZoom(data.getData());
        }
        
        if (requestCode == PHOTORESOULT) {
//        	if (data != null)
//        	{
//                Bundle extras = data.getExtras();
//                System.out.println("data data.getExtras()");
//                if (extras != null) {
                	//Bitmap photo = extras.getParcelable("data");
                	try {
    					Bitmap photo = BitmapFactory.decodeStream(activity.getContentResolver().openInputStream(uritempFile));
    	                ByteArrayOutputStream stream = new ByteArrayOutputStream();
    	                photo.compress(Bitmap.CompressFormat.JPEG, 75, stream);
    	                saveMyBitmap(imagepath, photo);
    	            
                	} catch (FileNotFoundException e) {
    					// TODO Auto-generated catch block
    					e.printStackTrace();
    				}  
//                }
//        	}
  
        	cppCallbackWithPath(imagepath);
            Log.v("gooooogle","onActivityResult()="+imagepath);
        }
        
        if(requestCode == AUDIOLOCAL){
        	Log.v("MyServer", "data.getData()"+data.getData());
        	String filename = FilePathUtil.fromUrlData(activity, data.getData());
        	cppCallbackWithPath(filename);
        }
	}
	
	public void startPhotoZoom(Uri uri) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        intent.setDataAndType(uri, intentTypeImage);
        intent.putExtra("crop", "true");
        intent.putExtra("aspectX", 1);
        intent.putExtra("aspectY", 1);
        intent.putExtra("outputX", 48);
        intent.putExtra("outputY", 48);
        //intent.putExtra("return-data", true);
     
//        /**  
//         * 姝ゆ柟娉曡繑鍥炵殑鍥剧墖鍙兘鏄皬鍥剧墖锛坰umsang娴嬭瘯涓洪珮瀹�160px鐨勫浘鐗囷級  
//         * 鏁呭皢鍥剧墖淇濆瓨鍦║ri涓紝璋冪敤鏃跺皢Uri杞崲涓築itmap锛屾鏂规硶杩樺彲瑙ｅ喅miui绯荤粺涓嶈兘return data鐨勯棶棰�  
//         */        
//        //uritempFile涓篣ri绫诲彉閲忥紝瀹炰緥鍖杣ritempFile  
// 		 XXX/@ci_8888-8888-8888-8888.jpg
        imagepath = strFileStorage + "/@ci_" + UUID.randomUUID().toString() + ".jpg";
        uritempFile = Uri.parse("file://" + "/" + imagepath);  
        intent.putExtra(MediaStore.EXTRA_OUTPUT, uritempFile);  
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());  
      
        Log.v("MyService", "void startPhotoZoom()"+imagepath);
        activity.startActivityForResult(intent, PHOTORESOULT); 
    }
	
	public void saveMyBitmap(String filePath, Bitmap mBitmap){
    	File f = new File(filePath);
    	try {
    		f.createNewFile();
    	} catch (IOException e) {
    	}
    	FileOutputStream fOut = null;
    	try {
    		fOut = new FileOutputStream(f);
    	} catch (FileNotFoundException e) {
    		e.printStackTrace();
    	}
    	mBitmap.compress(Bitmap.CompressFormat.JPEG, 70, fOut);
    	try {
    		fOut.flush();
    	} catch (IOException e) {
    		e.printStackTrace();
    	}
    	try {
    		fOut.close();
    	} catch (IOException e) {
    		e.printStackTrace();
    	}
    }
	
	public static void setWifiRSSI(){
	    //wifi_service = (WifiManager)activity.getSystemService(activity.WIFI_SERVICE); 
	    //wifiInfo = wifi_service.getConnectionInfo();
	    
		wifiIntentFilter = new IntentFilter();
		wifiIntentFilter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
		wifiIntentReceiver = new BroadcastReceiver(){
			@Override
			public void onReceive(Context context, Intent intent) {
				// TODO Auto-generated method stub
	    		int wifi_state = intent.getIntExtra("wifi_state", 0);
	    		int level = Math.abs(((WifiManager)activity.getSystemService(activity.WIFI_SERVICE)).getConnectionInfo().getRssi());
//	    		switch (wifi_state) {
//	    		case WifiManager.WIFI_STATE_DISABLING:
//	    			break;
//	    		case WifiManager.WIFI_STATE_DISABLED:
//	    			break;
//	    		case WifiManager.WIFI_STATE_ENABLING:
//	    			break;
//	    		case WifiManager.WIFI_STATE_ENABLED:
//	    			break;
//	    		case WifiManager.WIFI_STATE_UNKNOWN:
//	    			break;
//	    		default:
//	    			break;
//	    		}
	    		Log.v("My Server", "getWifiRSSI() onReceive:" + wifi_state + "level" + level);
	    		cppCallbackWithPath(""+level);
			}
		};
		activity.registerReceiver(wifiIntentReceiver, wifiIntentFilter);  
	}
	
	static public void setSignalStrength(){
		
    	telephoneManager = (TelephonyManager) activity.getSystemService(Context.TELEPHONY_SERVICE);
		final int type = telephoneManager.getNetworkType();  
	    phoneStateListener = new PhoneStateListener() {
            @Override  
            public void onSignalStrengthsChanged(SignalStrength signalStrength) {  
                // TODO Auto-generated method stub  
                super.onSignalStrengthsChanged(signalStrength);  
                StringBuffer sb = new StringBuffer();  
                String strength = String.valueOf(signalStrength  
                        .getGsmSignalStrength());  
                if (type == TelephonyManager.NETWORK_TYPE_UMTS  
                        || type == TelephonyManager.NETWORK_TYPE_HSDPA) {  
                    sb.append("鑱旈��3g").append("淇″彿寮哄害:").append(strength);  
                } else if (type == TelephonyManager.NETWORK_TYPE_GPRS  
                        || type == TelephonyManager.NETWORK_TYPE_EDGE) {  
                    sb.append("绉诲姩鎴栬�呰仈閫�2g").append("淇″彿寮哄害:").append(strength);  
                }else if(type==TelephonyManager.NETWORK_TYPE_CDMA){  
                    sb.append("鐢典俊2g").append("淇″彿寮哄害:").append(strength);  
                }else if(type==TelephonyManager.NETWORK_TYPE_EVDO_0  
                        ||type==TelephonyManager.NETWORK_TYPE_EVDO_A){  
                    sb.append("鐢典俊3g").append("淇″彿寮哄害:").append(strength);  
                      
                }else{  
                    sb.append("闈炰互涓婁俊鍙�").append("淇″彿寮哄害:").append(strength);  
                }  
  
                //toast.setText(sb.toString());  
                //toast.show();  
                //Log.v("MyService", "onSignalStrengthsChanged()"+sb.toString());
                //cppCallbackWithPath(sb.toString());
            }  
        };
        telephoneManager.listen(phoneStateListener, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);  
	}

	 /** 
	  * 开始录制 
	  */
	 static public void openRecord(){ 
	  /** 
	   * mediaRecorder.setAudioSource设置声音来源。 
	   * MediaRecorder.AudioSource这个内部类详细的介绍了声音来源。 
	   * 该类中有许多音频来源，不过最主要使用的还是手机上的麦克风，MediaRecorder.AudioSource.MIC 
	   */
	  mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC); 
	  /** 
	   * mediaRecorder.setOutputFormat代表输出文件的格式。该语句必须在setAudioSource之后，在prepare之前。 
	   * OutputFormat内部类，定义了音频输出的格式，主要包含MPEG_4、THREE_GPP、RAW_AMR……等。 
	   */
	  mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP); 
	  /** 
	   * mediaRecorder.setAddioEncoder()方法可以设置音频的编码 
	   * AudioEncoder内部类详细定义了两种编码：AudioEncoder.DEFAULT、AudioEncoder.AMR_NB 
	   */
	  mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.DEFAULT); 
	  /** 
	   * 设置录音之后，保存音频文件的位置 
	   */
	  strFileRecord = "file:///sdcard/myvido/a.3pg";
	  mediaRecorder.setOutputFile(strFileRecord); 
	    
	  /** 
	   * 调用start开始录音之前，一定要调用prepare方法。 
	   */
	  try { 
	   mediaRecorder.prepare(); 
	   mediaRecorder.start(); 
	  } catch (IllegalStateException e) { 
	   e.printStackTrace(); 
	  } catch (IOException e) { 
	   e.printStackTrace(); 
	  } 
	    
	 } 
	 static public void stopRecord()
	 {
		 mediaRecorder.stop();
		 cppCallbackWithPath(strFileRecord);
		 
     	 File recordFile = new File(strFileRecord);
		 MediaPlayer mPlayer = null;  
		 mPlayer = MediaPlayer.create(activity.getBaseContext(), Uri.fromFile(recordFile));  
		 mPlayer.setLooping(true);  
		 mPlayer.start();  
	 }
	 /*** 
	  * 此外，还有和MediaRecorder有关的几个参数与方法，我们一起来看一下： 
	  * sampleRateInHz :音频的采样频率，每秒钟能够采样的次数，采样率越高，音质越高。 
	  * 给出的实例是44100、22050、11025但不限于这几个参数。例如要采集低质量的音频就可以使用4000、8000等低采样率 
	  * 
	  * channelConfig ：声道设置：android支持双声道立体声和单声道。MONO单声道，STEREO立体声 
	  * 
	  * recorder.stop();停止录音 
	  * recorder.reset(); 重置录音 ，会重置到setAudioSource这一步 
	  * recorder.release(); 解除对录音资源的占用 
	  */
	
}



