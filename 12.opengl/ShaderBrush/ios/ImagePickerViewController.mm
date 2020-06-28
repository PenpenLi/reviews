#import "ImagePickerViewController.h"
#import "cocos2d.h"
#import "PhotoManager.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self localPhoto];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)localPhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"-(void)UIImagePickerControllerSourceTypePhotoLibrary();");
    }
        
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate      = self;
    picker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    
//    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation]))
//    {
//        picker.cameraViewTransform = CGAffineTransformMakeRotation(M_PI/2);
//    }
    
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        [self presentModalViewController:picker animated:YES];
    }
    else
    {
        [self presentViewController:picker animated:YES completion:^(void){
            NSLog(@"Imageviewcontroller is presented");
            [[PhotoManager getInstance] setShuping];
        }];
    }
    [picker release];
    
    NSLog(@"-(void)localPhoto();");
}

- (void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图像可编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
        {
            [self presentModalViewController:picker animated:YES];
        }
        else
        {
            [self presentViewController:picker animated:YES completion:^(void){
                NSLog(@"拍照Imageviewcontroller is presented");
                [[PhotoManager getInstance] setShuping];
            }]; 
        }
        [picker release];

    }
    else{
        [[PhotoManager getInstance] setHengping];
        NSLog(@"模拟器中无法打开照相机，请在真机中调试");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* imageNormal = nil;
        // 判断，图片是否允许修改
        if ([picker allowsEditing]){
            //获取用户编辑之后的图像
            imageNormal = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            // 照片的元数据参数
            imageNormal = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        }
        UIImage *image = [self thumbnailWithImageWithoutScale:imageNormal size:CGSizeMake(48, 48)];

        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //生成唯一字符串
        NSString* uuid = [[NSUUID UUID] UUIDString];
        
        //文件名
        NSString* fileName = [NSString stringWithFormat:@"/%@.png", uuid];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为XXXXXXXX-XXXX-XXXX....XXXX.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:fileName] contents:data attributes:nil];
        
        
        //得到选择后沙盒中图片的完整路径
        filePath = [[NSString alloc]initWithFormat:@"%@%@", DocumentsPath, fileName];
        
        //关闭相册界面
        [[PhotoManager getInstance] setHengping];
        if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
        {
            [picker dismissModalViewControllerAnimated:YES];
        }else{
            [picker dismissViewControllerAnimated:YES completion:^{
            }];
        }
        
        std::string strFilePath = [filePath UTF8String];
        cocos2d::Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("AndroidDisposerEvent", &strFilePath);
    }
    else{
        [[PhotoManager getInstance] setHengping];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"您取消了选择图片");
    [[PhotoManager getInstance] setHengping];
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        [picker dismissModalViewControllerAnimated:YES];
    }else{
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
    }
    NSLog(@"取消");
}

#pragma mark -

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 2;
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

@end


