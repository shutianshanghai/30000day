//
//  userInfoViewController.m
//  30000天
//
//  Created by wei on 16/1/19.
//  Copyright © 2016年 wei. All rights reserved.
//

#import "userInfoViewController.h"
#import "userInfoTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HZAreaPickerView.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ZYQAssetPickerController.h"
#import "ZHPickView.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface userInfoViewController () <UINavigationControllerDelegate,ZHPickViewDelegate,UIAlertViewDelegate,VPImageCropperDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)UserProfile* userProfile;

@property (nonatomic,strong)NSArray* titleArray;

@property (nonatomic,strong)ZHPickView* zpk;

@property (nonatomic,strong) UIImageView *portraitImageView;

@property (nonatomic,assign) NSInteger mainTableState;

@property (nonatomic,copy)NSString* NickName;

@property (nonatomic,copy)NSString* Gender;

@property (nonatomic,copy)NSString* Birthday;

@end

@implementation userInfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    UIBarButtonItem* rightBarButton=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.mainTableState = 0;
    
    [self.mainTable setDelegate:self];
    
    [self.mainTable setDataSource:self];
    
    _userProfile = [UserAccountHandler shareUserAccountHandler].userProfile;
    
    self.NickName = _userProfile.NickName;
    
    self.Gender = _userProfile.Gender;
    
    self.Birthday=_userProfile.Birthday;
    
    _titleArray = [NSArray arrayWithObjects:@"头像",@"昵称",@"性别",@"生日",nil];
    
    self.mainTable.scrollEnabled = NO;
    
}

- (void)rightBarButtonClick:(UIBarButtonItem *)button{
    if ([button.title isEqualToString:@"编辑"]) {
        button.title=@"保存";
        self.mainTableState=1;
    }else{
        button.title=@"编辑";
        self.mainTableState=0;
        [self updInfo];
    }
    [self.mainTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 4;
        
    } else {
        
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            return 105;
        }else{
            return 43;
        }
    }else{
        return 43;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* ID=@"userInfoTableViewCell";
    userInfoTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        NSBundle* bundle=[NSBundle mainBundle];
        NSArray* objs=[bundle loadNibNamed:@"userInfoTableViewCell" owner:nil options:nil];
        cell=[objs lastObject];
    }
    
    if (self.mainTableState) {
        cell.detailTextLabel.textColor=[UIColor blackColor];
    }else{
        cell.detailTextLabel.textColor=[UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:185.0/255.0 alpha:1.0];
    }
    
    if (indexPath.section==0) {
        cell.textLabel.text=self.titleArray[indexPath.row];
        if (indexPath.row==0) {
            NSURL* imgurl=[NSURL URLWithString:_userProfile.HeadImg];
            UIImageView* imgview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 65, 65)];
            if ([[NSString stringWithFormat:@"%@",imgurl] isEqualToString:@""] || imgurl==nil ) {
                [imgview setImage:[UIImage imageNamed:@"lcon.png"]];
            }else{
                [imgview sd_setImageWithURL:imgurl];
            }
            [cell addSubview:imgview];
            imgview.translatesAutoresizingMaskIntoConstraints=NO;
            [imgview addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:65]];
            [imgview addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:65]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [cell addConstraint:[NSLayoutConstraint constraintWithItem:imgview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:-28]];
            self.portraitImageView=imgview;

        }else if(indexPath.row==1){
            
            cell.detailTextLabel.text=_userProfile.NickName;
            
        }else if(indexPath.row==2){
            
            if ([_userProfile.Gender isEqualToString:@"1"]) {
                
                cell.detailTextLabel.text = @"男";
                
            } else {
                
                cell.detailTextLabel.text = @"女";
            }
            
        }else if(indexPath.row == 3){
            
            cell.detailTextLabel.text=_userProfile.Birthday;
        }
        
    }else{
        cell.textLabel.text=@"账号";
        cell.detailTextLabel.text=_userProfile.LoginName;
        cell.detailTextLabel.textColor=[UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:185.0/255.0 alpha:1.0];
    }
    
    return cell;

}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView* view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43)];
    
    [view setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]];
    
    return view;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.mainTableState) {
        
        if (indexPath.section==0) {
            
            if (indexPath.row==0) {
                
                [self editPortrait];
                
            }else if(indexPath.row==1){
                
                UIAlertView* alert=[[UIAlertView alloc]initWithTitle:_userProfile.NickName message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                
                UITextField* textfile=[alert textFieldAtIndex:0];
                
                [textfile setText:_userProfile.NickName];
                
                [alert show];
                
            } else if(indexPath.row==2) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择性别"message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女", nil];
                
                [alertView show];
                
            } else if(indexPath.row==3) {
                
                NSString *currentDate = [UserAccountHandler shareUserAccountHandler].userProfile.Birthday;
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                
                [formatter setDateFormat:@"yyyy/MM/dd"];
                
                _zpk = [[ZHPickView alloc] initDatePickWithDate:[formatter dateFromString:currentDate] datePickerMode:UIDatePickerModeDate isHaveNavControler:YES];
                
                _zpk.delegate = self;
                
                [_zpk setMaxMinYer];
                
                [_zpk show];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSIndexPath *indexpath = self.mainTable.indexPathForSelectedRow;

    if ( indexpath.section == 0 && buttonIndex!= 0 ) {
        
        if (indexpath.row == 1 ) {
            
            UITextField *textfile = [alertView textFieldAtIndex:0];
            
            _userProfile.NickName=textfile.text;
        }
        if (indexpath.row==2) {
            
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"男"]) {
                
                _userProfile.Gender = @"1";
                
            } else {
                
                _userProfile.Gender = @"0";
                
            }
        }

        [self.mainTable reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    NSDateFormatter *datef = [[NSDateFormatter alloc] init];
    
    [datef setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    NSDate *now = [datef dateFromString:resultString];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: now];
    
    NSDate *localeDate = [now  dateByAddingTimeInterval: interval];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:localeDate];
    
    NSString *Birthday = [NSString stringWithFormat:@"%d/%d/%d",(int)[dateComponent year],(int)[dateComponent month],(int)[dateComponent day]];
    
    _userProfile.Birthday = Birthday;
    
    [UserAccountHandler shareUserAccountHandler].userProfile = _userProfile;
    
     [self.mainTable reloadData];
}

- (void)updInfo {
    
    if ([self.NickName isEqualToString:_userProfile.NickName] &&
        [self.Gender isEqualToString:_userProfile.Gender] &&
        [self.Birthday isEqualToString:_userProfile.Birthday]) {
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您未做任何修改，如修改图片则无需再保存。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    //上传服务器
    [self.dataHandler postUpdateProfileWithUserID:_userProfile.UserID Password:_userProfile.LoginPassword PhoneNumber:_userProfile.LoginName NickName:_userProfile.NickName Gender:_userProfile.Gender Birthday:_userProfile.Birthday success:^(BOOL responseObject) {
        
        if (responseObject) {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"个人信息保存成功。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } failure:^(NSError *error) {
        
        UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"保存出错。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }];

    // 保存生日到本地文件，用于其他地方提取计算数值
    [[NSUserDefaults standardUserDefaults] setObject:[_userProfile.Birthday stringByAppendingString:@" 00:00:00"] forKey:@"UserBirthday"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)shangchuantupian:(UIImage*)img {
    
    //第一步，创建URL
    NSString *URLString = @"http://116.254.206.7:12580/M/API/UploadPortrait?";//不需要传递参数
    
    NSURL *URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //第二步，创建请求
    
    //    2.创建请求对象
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL];
    
    //设置请求体
    NSString *param = [NSString stringWithFormat:@"loginName=%@&loginPassword=%@&base64Photo=%@&photoExtName=%@",_userProfile.LoginName,_userProfile.LoginPassword,[self image2DataURL:img][1],[self image2DataURL:img][0]];
    
    //把拼接后的字符串转换为data，设置请求体
    NSData * postData = [param dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"post"]; //指定请求方式
    
    [request setURL:URL]; //设置请求的地址
    
    [request setHTTPBody:postData];  //设置请求的参数
    
    NSURLResponse * response;
    
    NSError * error;
    
    NSData * backData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        //访问服务器失败进此方法
        NSLog(@"error : %@",[error localizedDescription]);
        
        [self showToast:@"图片上传失败"];
        
    }else{
        
        //成功访问服务器，返回图片的URL
        NSLog(@"backData : %@",[[NSString alloc]initWithData:backData encoding:NSUTF8StringEncoding]);
        
        _userProfile.HeadImg = [[NSString alloc]initWithData:backData encoding:NSUTF8StringEncoding];
        
        [UserAccountHandler shareUserAccountHandler].userProfile = _userProfile;
    }
}

// 判断图片后缀名的方法
- (BOOL) imageHasAlpha: (UIImage *) image {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

// 把图片转换成base64位字符串，返回数组［0］：图片后缀名(.png/.jpeg)--［1］：base64位字符串
- (NSArray *) image2DataURL: (UIImage *) image {
    
    NSData *imageData = nil;
    
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        
        imageData = UIImagePNGRepresentation(image);
        
        mimeType = @".png";
        
    } else {
        
        imageData = UIImageJPEGRepresentation(image, 1.0f);
        
        mimeType = @".jpeg";
    }
    
    NSString *baseStr = [imageData base64Encoding];
    
    // 转成base64位字符串之后要进行下面这一步替换，不然传到后台之后，加号等于号等一些特殊字符会变成空格，导致图片出问题
    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)baseStr,NULL,CFSTR(":/?#[]@!$&’()*+,;="),kCFStringEncodingUTF8);
    
    NSArray *arr = [NSArray arrayWithObjects:mimeType,baseString, nil];
    
    return arr;
}

- (void)editPortrait {
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    self.portraitImageView.image = editedImage;
    
    [self shangchuantupian:editedImage];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO  ok
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"ddd");
        
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
            NSLog(@"aaa");
        }];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        NSLog(@"bbb");
    }];
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
