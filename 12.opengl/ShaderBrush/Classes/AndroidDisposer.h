#ifndef _ANDRIODDISPOSER_H_
#define _ANDRIODDISPOSER_H_

#include "cocos2d.h"
#include "ui/CocosGUI.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#endif	

class AndroidDisposer
{
private:
	std::function<void(std::string)> m_callback;
	static AndroidDisposer* s_instance;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	void* m_viewController;
#endif 

private:
	AndroidDisposer();
	bool init();
	void setListener(const std::function<void(std::string)>& callback);
	void removeListener();
	void openPhoto();
	void openCamera();
	void openAudio();
	void addListItem(cocos2d::ui::ListView *pListView, const std::string& strBack, 
		const std::string& strText, const std::function<void(cocos2d::Ref*)>& callback);
	
public:
	// 获取选择器单例
	static AndroidDisposer* getInstance();
	void callAndroidDisposer(const std::function<void(std::string)>& callback);
	static void destoryInstance();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	// 设置AppController
	void setViewController(void* viewController);
#endif 
};

#endif // _ANDRIODDISPOSER_H_