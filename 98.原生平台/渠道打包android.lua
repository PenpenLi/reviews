https://juejin.im/post/5cc671006fb9a031fd63491e
https://www.jianshu.com/p/bfdee92ab355

--[[ 模块 build.gradle;
apply plugin: 'com.android.application'
android {
    compileSdkVersion 28
    buildToolsVersion "28.0.2"
    defaultConfig {
        applicationId "net.sourceforge.decyhblhz"
        minSdkVersion 17
        targetSdkVersion 28
        versionCode 111
        versionName "9.54"
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"

        //版本名后面添加一句话，意思就是flavor dimension 它的维度就是该版本号，这样维度就是都是统一的了
        flavorDimensions "versionCode"
    }
    useLibrary 'org.apache.http.legacy'


    //构建类型======================================
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
//            //
//            storeFile file("../yourapp.keystore") //签名证书文件
//            storePassword "your password"         //签名证书密码
//            keyAlias "your alias"                 //别名
//            keyPassword "your password"           //别名密码
        }
        debug {
            applicationIdSuffix ".debug"
        }
        // 自定义的构建类型，名字随便取，一定要有意义
        raedebug {
            initWith release
            applicationIdSuffix '.raedebug'
        }
    }


    //渠道包定义，默认定义的名称就是渠道名称
    productFlavors {
        dev {
//            applicationId "com.xxx.xxxx"
            //不同渠道商信息的配置其实和修改包名差不多
//            buildConfigField "int", "AGENT_ID", "1"//渠道商ID
//            这样编译后在BuildConfig文件下生成：public static final int AGENT_ID = 1;
//            然后你就可以BuildConfig.AGENT_ID 这样引用。
            buildConfigField "String", "AGENT_NAME", "\"Ahello\""//渠道商名称
            //修改应用名
//            resValue "string", "app_name", "Ahello"//应用名
//            需要注意的是这个是resValue 是增加一个值，如果你在string.xml中已经有一个app_name，请先删除，否则编译不过
            resValue "string", "copyright", "Ahello @ 2018"
            //修改图片,修改资源
//            AndroidManifest.xml里android:icon="${app_icon}"
//            manifestPlaceholders = [app_icon: "@drawable/logo_xxxx"]//应用图标
            manifestPlaceholders = [UMENG_CHANNEL_VALUE: "wandoujia"]

            // xxx
            构建源的命名规则如下：productFlavor 表示渠道包，可以看下面的多渠道打包
//            src/main/ 此源集包括所有构建变体共用的代码和资源。
//            src/<buildType>/ 创建此源集可加入特定构建类型专用的代码和资源。示例：src/jnidebug
//            src/<productFlavor>/ 创建此源集可加入特定产品风味专用的代码和资源。比如百度渠道包：src/baidu
//            src/<productFlavorBuildType>/ 创建此源集可加入特定构建变体专用的代码和资源。
            //这种方法可以有效解决换图片问题，同时，还可以替换assets文件夹文件，甚至java类文件
            sourceSets {
                Ahello {
                    res.srcDirs = ['src_custom/Ahello/res']//替换res文件
                    rassets.srcDirs = ['src_custom/Ahello/assets']//替换assets文件
                    java.srcDirs = ['src_custom/Ahello/java']//替换java类文件
                }
            }
        } //测试
        official {

        } //官方版本
        baidu {

        } //百度手机助手
        _360 {

        } // 或“"360"{}”，数字需下划线开头或加上双引号
    }
    //批量渠道包替换
//    productFlavors.all {
//        flavor->
//            //友盟、极光推送渠道包，UMENG_CHANNEL是根据AndroidManifest.xml来配置的
//            flavor.manifestPlaceholders = {UMENG_CHANNEL:name, JPUSH_CHANNEL:name}
//    }


    //输出文件配置
    applicationVariants.all { variant->
        variant.outputs.each {  output->
            def outputFile = output.outputFile
            if (outputFile != null && outputFile.name.endsWith(".apk")) {
                def dirName = "./" //outputFile.parent //输出文件夹所在的位置
                //文件名修改
                def fileName = "app-${output.processResources.variantName}-${defaultConfig.versionName}-${variant.flavorName}.apk"
                output.outputFileName = new File(dirName, fileName)
            }
        }
    }
    // 上面介绍的多渠道打包是采用gralde默认的配置，但有个弊端是每个渠道包都会重新编译一次，编译速度慢。
    // 对大量的多渠道打包推荐用美团的walle
}


dependencies {
    implementation fileTree(dir: './libs', include: ['*.jar'])
    implementation 'com.android.support:appcompat-v7:28.0.0'
    implementation 'com.android.support.constraint:constraint-layout:1.1.3'
    implementation 'com.google.android.gms:play-services-ads:15.0.1'
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'com.android.support.test:runner:1.0.2'
    androidTestImplementation 'com.android.support.test.espresso:espresso-core:3.0.2'

//    // 生成环境依赖
//    releaseCompile project(path: ':sdk', configuration: 'release')
//    // 测试环境依赖
//    debugCompile project(path: ':sdk', configuration: 'debug')
//    // 自定义构建类型依赖
//    raedebugCompile project(path: ':sdk', configuration: 'uutest')
}

--]]
























