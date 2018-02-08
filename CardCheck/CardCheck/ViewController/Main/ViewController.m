//
//  ViewController.m
//  CardCheck
//
//  Created by itnesPro on 12/20/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "ViewController.h"

#import "InitializationData.h"
#import "ReaderController.h"

#import "NSData+AES.h"

@interface ViewController ()<ReaderControllerDelegate, CardImagePickerDelegate>

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReader *currentReader;
@property (nonatomic, strong) InitializationData *devInitData;

@property (nonatomic, strong) ReaderController *readerController;
@property (nonatomic, strong) CardImagePicker *cardImagePickerController;

@property (nonatomic, strong) NSArray *stackOfResponse;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Base init
    self.stackOfResponse = @[];
    self.keyChain = [KeyChainData sharedInstance];
    self.currentReader = [CardReader demoData];
    self.cardImagePickerController = [[CardImagePicker alloc] initWithDelegate: self];

    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
    NSLog(@"currentReader = %@", [self.currentReader debugDescription]);
    NSLog(@"manData = %@", [[MandatoryData sharedInstance] debugDescription]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Working

- (void)completeInitialization
{
    CryptoController *crp = [CryptoController sharedInstance];
    
    //Otp
    [self.keyChain setOtp: self.devInitData.otp];
    
    //Transport
    NSString *hexTransportKey = [crp calcTransportKey: self.devInitData];
    [self.keyChain setTransportKey: hexTransportKey];
    
    //AppKeys
    NSData *appKeys = [crp aes128DecryptHexData: [self.devInitData cipherAppKeys]
                                     withHexKey: self.keyChain.transportKey];
    
    NSData *appDataKey = [appKeys subdataWithRange: NSMakeRange(0, 32)];
    [self.keyChain setAppDataKey: [HexCvtr hexFromData: appDataKey]];
    
    NSData *appCommKey = [appKeys subdataWithRange: NSMakeRange(32, 32)];
    [self.keyChain setAppCommKey: [HexCvtr hexFromData: appCommKey]];
    
    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
    
    //Complete
    MandatoryData *manData = [MandatoryData sharedInstance];
    [manData setAppID: self.devInitData.appID];
    [manData setDeviceID: self.currentReader.deviceID];
    
    [manData setAppDataKey: self.keyChain.appDataKey];
    [manData setAppCommKey: self.keyChain.appCommKey];
    
    [manData save];
    
    NSLog(@"MandatoryData = %@", [manData debugDescription]);
}

#pragma mark - Actions

- (IBAction)start:(id)sender {
    self.readerController = [ReaderController sharedInstance];
    [self.readerController setDelegate: self];
    
    [self.readerController startIfNeeded];
}

- (IBAction)reset:(id)sender {
    self.readerController = [ReaderController sharedInstance];
    [self.readerController reset];
}

- (IBAction)auth:(id)sender
{
    AuthRequestModel *request = [AuthRequestModel requestWithLogin: DEMO_LOGIN
                                                         andReader: self.currentReader];
    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendAuthRequest: request
                                     withCompletion:^(AuthResponseModel *model, NSError *error) {
                                         if (model.isCorrect)
                                         {
                                             weakSelf.devInitData = [InitializationData new];
                                             [weakSelf.devInitData setupWithAuthResponse: model];
                                             
                                             NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                         }
                                         else {
                                             NSLog(@"response = %@", model);
                                         }
                                     }];
}

- (IBAction)calcOtp:(id)sender
{
    CryptoController *crp = [CryptoController sharedInstance];
    NSString *value = [crp calcOtp: self.devInitData.authResponseTime];
    [self.devInitData setupWithCalculatedOtp: value];

    NSLog(@"otp = %@", value);
    NSLog(@"devInitData = %@", [self.devInitData debugDescription]);
}

- (IBAction)initialization:(id)sender
{
    //NSUInteger typedOtp = [self.typedOtp.text integerValue];
    NSString *typedOtp = self.devInitData.otp;
    if ([self.devInitData.otp isEqualToString: typedOtp])
    {
        InitRequestModel *request = [InitRequestModel requestWithData: self.devInitData
                                                                  andReader: self.currentReader];
        __weak ViewController *weakSelf = self;
        [[APIController sharedInstance] sendDevInitRequest: request
                                            withCompletion:^(InitResponseModel *model, NSError *error)
        {
            if (model.isCorrect)
            {
                [weakSelf.devInitData setupWithInitResponse: model];
                NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                
                [weakSelf completeInitialization];
            }
            else {
                NSLog(@"response = %@", model);
            }
        }];
    }
}

- (IBAction)checkCard:(id)sender
{
    self.stackOfResponse = @[];
    
    AesTrackData *trackData = [AesTrackData demoData];
    
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    [self.currentReader setTrackData: trackData];
    
    CCheckRequestModel *request = [CCheckRequestModel requestWithReader: self.currentReader];
    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendCCheckRequest: request
                                       withCompletion:^(CCheckResponseModel *model, NSError *error)
    {
        NSLog(@" response = %@", [model debugDescription]);
        weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: model];
    }];
}

- (CCheckResponseModel *)lastCheckResponse
{
    __block CCheckResponseModel *target = nil;
    [self.stackOfResponse enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass: [CCheckResponseModel class]]) {
            target = obj;
            *stop = YES;
        }
    }];
    
    return target;
}

- (NSArray<CardImage *> *)fakeCardImages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", [self lastCheckResponse]];
    return [self.stackOfResponse filteredArrayUsingPredicate: predicate];
}

- (IBAction)completeCheckCard:(id)sender
{
    AesTrackData *trackData = [AesTrackData demoData];
    trackData.plainHexData = [NSString stringWithFormat:@"%@%@", trackData.plainHexData, DEMO_PAN];
    
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    [self.currentReader setTrackData: trackData];
    
    CFinishCheckRequestModel *request = [CFinishCheckRequestModel requestWithReader: self.currentReader];
    [request setCheckResponse: [self lastCheckResponse]];
    [request setupFakeCardWithImages: [self fakeCardImages]];
    
    //__weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendCFinishCheckRequest: request
                                             withCompletion:^(CFinishCheckResponseModel *model, NSError *error)
    {
        NSLog(@" response = %@", [model debugDescription]);
    }];
}

- (IBAction)uploadCardImage:(id)sender
{
    [self.cardImagePickerController presentInView: self];
}

- (void)uploadImage:(CardImage *)image
{
    CCheckResponseModel *report = [self lastCheckResponse];
    CUploadRequestModel *request = [CUploadRequestModel requestWithReportID: report.reportID
                                                                 reportTime: report.time
                                                                  cardImage: image];

    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] uploadImageRequest: request
                                        withCompletion:^(CUploadResponseModel *model, NSError *error)
     {
         NSLog(@" response = %@", [model debugDescription]);
         
         [image setID: model.imgID];
         weakSelf.stackOfResponse = [weakSelf.stackOfResponse arrayByAddingObject: image];
     }];
}

- (IBAction)testCrypto:(id)sender
{
    //*init
    NSString *key = nil;
    //NSString *sign = nil;
    NSData *cipherData = nil;
    NSData *decryptData = nil;
    CryptoController *crp = [CryptoController sharedInstance];
    
//    //Transport key
//    self.devInitData = [InitializationData demoData];
//    NSLog(@"devInitData = %@", [self.devInitData debugDescription]);
//    
//    NSString *hexTransportKey = [crp calcTransportKey: self.devInitData];
//    
//    [self.keyChain setOtp: self.devInitData.otp];
//    [self.keyChain setTransportKey: hexTransportKey];
//    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
    
    //AES
    NSString *plainData = DEMO_TRACK_DATA;
    NSLog(@"plain data = %@", plainData);
    
    //*go
    NSLog(@"\n\n ________ AES128 ________ \n\n");

    key = DEMO_AES128_KEY;
    NSLog(@"key128 = \n%@", key);
    cipherData = [crp aes128EncryptHexData: plainData
                                withHexKey: key];
    NSLog(@"cipherData128 = \n%@", [HexCvtr hexFromData: cipherData]);

    decryptData = [crp aes128DecryptHexData: [HexCvtr hexFromData: cipherData]
                                 withHexKey: key];
    NSLog(@"decryptData128 = \n%@", [HexCvtr hexFromData: decryptData]);
    
    NSLog(@"\n\n ________ AES256 ________ \n\n");
    
    key = DEMO_AES256_KEY;
    NSLog(@"key256 = \n%@", key);
    cipherData = [crp aes256EncryptHexData: plainData
                                withHexKey: key];
    NSLog(@"cipherData256 = \n%@", [HexCvtr hexFromData: cipherData]);
    
    decryptData = [crp aes256DecryptHexData: [HexCvtr hexFromData: cipherData]
                                 withHexKey: key];
    NSLog(@"decryptData256 = \n%@", [HexCvtr hexFromData: decryptData]);
    
//    NSLog(@"\n\n ________ подпись JSON (алгоритм 1) ________ \n\n");
//    sign = [crp calcSignature1: [HexCvtr dataFromHex: plainData]];
//    NSLog(@"%@", sign);
//
//    NSLog(@"\n\n ________ подпись JSON (алгоритм 2) ________ \n\n");
//    sign = [crp calcSignature2: [HexCvtr dataFromHex: plainData]];
//    NSLog(@"%@", sign);
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didUpdateWithReader:(CardReader *)reader
{
    NSLog(@"%@: data => %@", CURRENT_METHOD, [reader debugDescription]);
}

#pragma mark - CardImagePickerDelegate

- (void)cardPicker:(CardImagePicker *)picker didPickCardImage:(CardImage *)image
{
    [picker dismissInView: self];
    [self uploadImage: image];
}

- (void)cardPickerDidCancelPicking:(CardImagePicker *)picker
{
    [picker dismissInView: self];
}


@end
