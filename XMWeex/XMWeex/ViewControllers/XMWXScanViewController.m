//
//  @header XMWXScanViewController.m
//  @abstract <##>
//  @version <##> 2017/5/20
//  XMWeex
//
//  Created by apple on 2017/5/20.
//  Copyright © 2017年 龙源数字传媒. All rights reserved.
//


#import "XMWXScanViewController.h"
#import <WeexSDK/WeexSDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface BaseTapSound(){
    SystemSoundID soundID;
    SystemSoundID systemSoundID;
}

@end

@implementation BaseTapSound

- (void)dealloc{
    AudioServicesDisposeSystemSoundID(soundID);
}

static BaseTapSound *baseSound;
+(instancetype)shareTapSound{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (baseSound == nil) {
            baseSound=[[self alloc]init];
            baseSound.vibrate = YES;
        }
    });
    return baseSound;
}

- (void)playSoundFileName:(NSString *)soundName{
    NSURL *url=[[NSBundle mainBundle]URLForResource:soundName withExtension:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    
}

- (void)playSound{
    if (self.vibrate) {
        AudioServicesPlayAlertSound(soundID);
    }else{
        AudioServicesPlaySystemSound(soundID);
    }
    
}

- (void)playSystemSound{
    //系统声音
    AudioServicesPlaySystemSound(1007);
    if (self.vibrate) {
        //震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

+ (BOOL)ifCanUseSystemCamera{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        return NO;
    }
    return YES;
}
/**
 * 是否有权限使用系统相册
 */
+ (BOOL)ifCanUseSystemPhoto {
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}


@end

#import <AVFoundation/AVFoundation.h>
#define DEVICE_WIDTH   [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT  [UIScreen mainScreen].bounds.size.height
@interface XMWXScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    SystemSoundID soundID;
    float move;
}
@property (strong , nonatomic) AVCaptureDevice * device;
@property (strong , nonatomic) AVCaptureDeviceInput * input;
@property (strong , nonatomic) AVCaptureMetadataOutput * output;
@property (strong , nonatomic) AVCaptureSession * session;
@property (strong , nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (strong , nonatomic) UIImageView  *qrView;
@property (strong , nonatomic) UIImageView *lineLabel;
@property (strong , nonatomic) NSTimer *lineTimer;
@property (strong , nonatomic) UIView *otherPlatformLoginView;

@end

@implementation XMWXScanViewController

#pragma mark - public method

#pragma mark - private method

#pragma mark - getter

#pragma mark - setter

#pragma mark - life Cycle

- (void)dealloc{
    if ([_lineTimer isValid]) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (_session) {
        [_session startRunning ];
        if (_lineTimer) {
            [_lineTimer invalidate];
            _lineTimer = nil;
        }
        _lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
        _lineLabel.hidden = NO;
        
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    move = 1.0;
    //扫描区域宽、高大小
    float QRWIDTH = 200/320.0*DEVICE_WIDTH;
    
    //创建扫描区域框
    _qrView=[[UIImageView alloc]init];
    _qrView.bounds = CGRectMake(0, 0, QRWIDTH, QRWIDTH);
    _qrView.center = CGPointMake(DEVICE_WIDTH/2.0, DEVICE_HEIGHT/2.0);
    _qrView.backgroundColor = [UIColor clearColor];
    _qrView.image = [UIImage imageNamed:@"QRImage.png"];
    [self.view addSubview:_qrView];
    
    _lineLabel = [[UIImageView alloc]initWithFrame:CGRectMake(_qrView.frame.origin.x+2.0, _qrView.frame.origin.y + 2.0, _qrView.frame.size.width - 4.0, 3.0)];
    _lineLabel.image = [UIImage imageNamed:@"QRLine.png"];
    [self.view addSubview:_lineLabel];
    
    
    //半透明背景
    UIView *qrBacView = [[UIView alloc]init];//上
    qrBacView.frame = CGRectMake(0, 64, DEVICE_WIDTH, _qrView.frame.origin.y - 64);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.6;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//左
    qrBacView.frame = CGRectMake(0, _qrView.frame.origin.y, _qrView.frame.origin.x,DEVICE_HEIGHT - _qrView.frame.origin.y);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.6;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//下
    qrBacView.frame = CGRectMake(_qrView.frame.origin.x, _qrView.frame.origin.y + QRWIDTH, DEVICE_WIDTH - _qrView.frame.origin.x, DEVICE_HEIGHT - _qrView.frame.origin.y - QRWIDTH);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.6;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//右
    qrBacView.frame = CGRectMake(_qrView.frame.origin.x + QRWIDTH, _qrView.frame.origin.y, DEVICE_WIDTH - _qrView.frame.origin.x - QRWIDTH, QRWIDTH);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.6;
    [self.view addSubview:qrBacView];
    
    
    [self canUseSystemCamera];
    
    //[self createOtherPlatformLoginView];
    
    
}

//创建扫描
- (void)createQRView{
    
    //扫描区域宽、高大小
    float QRWIDTH = 200/320.0*DEVICE_WIDTH;
    
    //手电筒开关
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(_qrView.frame.origin.x + QRWIDTH/2.0 - 20, _qrView.frame.origin.y + _qrView.frame.size.height + 20, 40, 40);
    btn.selected = NO;
    //    [btn setTitle:@"开启闪光灯" forState:UIControlStateNormal];
    //    [btn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"ocr_flash-off.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ocr_flash-on.png"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [ _output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue ()];
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    //设置扫描有效区域(上、左、下、右)
    [_output setRectOfInterest : CGRectMake (( _qrView.frame.origin.y )/ DEVICE_HEIGHT ,(_qrView.frame.origin.x)/ DEVICE_WIDTH , QRWIDTH / DEVICE_HEIGHT , QRWIDTH / DEVICE_WIDTH )];
    // Preview
    _preview =[ AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    _preview.frame = self.view.layer.bounds ;
    [self.view.layer insertSublayer:_preview atIndex:0];
    // Start
    [_session startRunning];
    
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
}
- (void)leftButtonHaveClick:(UIButton *)sender{
    if ([_lineTimer isValid]) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    [_device lockForConfiguration:nil];
    [_device setTorchMode:AVCaptureTorchModeOff];
    [_device unlockForConfiguration];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)moveLine{
    float upY = _qrView.frame.origin.y + _qrView.frame.size.height - 2.0 - 3.0;
    float y = _lineLabel.frame.origin.y;
    y = y+move;
    CGRect lineFrame=CGRectMake(_lineLabel.frame.origin.x, y, _qrView.frame.size.width - 4.0, 3.0);
    _lineLabel.frame = lineFrame;
    if (y < _qrView.frame.origin.y + 2.0 || y > upY) {
        move = -move;
    }
    
}

//扫描成功后的代理方法
- ( void )captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    NSString *stringValue;//扫描结果
    if ([metadataObjects count ] > 0 ){
        // 停止扫描
        [_session stopRunning];
        if ([_lineTimer isValid]) {
            [_lineTimer invalidate];
            _lineTimer = nil;
            _lineLabel.hidden = YES;
        }
        [[BaseTapSound shareTapSound]playSystemSound];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        stringValue = metadataObject. stringValue ;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"QRCodeResult" message:stringValue delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
        
        NSString * host = [[NSURL URLWithString:stringValue] host];
        NSNumber * port = [[NSURL URLWithString:stringValue] port];
        NSString * real = [NSString stringWithFormat:@"http://%@:%@/",host,port];
        objc_setAssociatedObject([UIApplication sharedApplication], &"host", real, OBJC_ASSOCIATION_COPY_NONATOMIC);
        NSArray * arr = [stringValue componentsSeparatedByString:@"?"];
        stringValue = arr.firstObject;
        objc_setAssociatedObject(alert, &"QRCodeString", stringValue, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [alert show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        WXSDKInstance * instance = [(UIResponder *)[UIApplication sharedApplication].delegate valueForKey:@"instance"];
        [instance destroyInstance];
        [(UIResponder *)[UIApplication sharedApplication].delegate setValue:nil forKey:@"instance"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [(UIResponder *)[UIApplication sharedApplication].delegate performSelector:@selector(instance:) withObject:objc_getAssociatedObject(alertView, &"QRCodeString")];
    }else
    {
        [self startingQRCode];
    }
    
}
- (void)openOrClose:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_device unlockForConfiguration];
    }else{
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }
}
- (void)canUseSystemCamera{
    if (![BaseTapSound ifCanUseSystemCamera]) {
        _lineLabel.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"此应用已被禁用系统相机" message:@"请在iPhone的 \"设置->隐私->相机\" 选项中,允许 \"飞熊视频\" 访问你的相机" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        alert.tag = 100;
        [alert show];
    }else{
        _lineLabel.hidden = NO;
        [self createQRView];
    }
}
- (void)startingQRCode{
    if (self.session) {
        [self.session startRunning ];
        if (self.lineTimer) {
            [self.lineTimer invalidate];
            self.lineTimer = nil;
        }
        self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
        self.lineLabel.hidden = NO;
    }
    
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
