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

@interface ViewController ()<ReaderControllerDelegate>

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReaderData *currentReader;
@property (nonatomic, strong) InitializationData *devInitData;
@property (nonatomic, strong) ReaderController *readerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Base init
//    self.keyChain = [KeyChainData sharedInstance];
//    self.currentReader = [CardReaderData demoData];
//
//    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
//    NSLog(@"currentReader = %@", [self.currentReader debugDescription]);
//    NSLog(@"manData = %@", [[MandatoryData sharedInstance] debugDescription]);
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
    
    [self.readerController start];
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
    int value = [crp calcOtp: self.devInitData.authResponseTime];
    [self.devInitData setupWithCalculatedOtp: value];

    NSLog(@"otp = %i", value);
    NSLog(@"devInitData = %@", [self.devInitData debugDescription]);
}

- (IBAction)initialization:(id)sender
{
    //NSUInteger typedOtp = [self.typedOtp.text integerValue];
    NSUInteger typedOtp = self.devInitData.otp;
    if (self.devInitData.otp == typedOtp)
    {
        InitRequestModel *request = [InitRequestModel requestWithData: self.devInitData
                                                                  andReader: self.currentReader];
        __weak ViewController *weakSelf = self;
        [[APIController sharedInstance] sendDevInitRequest: request
                                            withCompletion:^(InitResponseModel *model, NSError *error) {
                                                if (model.isCorrect)
                                                {
                                                    [weakSelf.devInitData setupWithInitResponse: model];
                                                    [weakSelf completeInitialization];
                                                    
                                                    NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                                }
                                                else {
                                                    NSLog(@"response = %@", model);
                                                }
                                            }];
    }
}

- (IBAction)checkCard:(id)sender
{
    AesTrackData *trackData = [AesTrackData demoData];
    
    CryptoController *crp = [CryptoController sharedInstance];
    NSData *cipherData = [crp aes256EncryptHexData: trackData.plainHexData
                                        withHexKey: [self.keyChain appDataKey]];
    [trackData setCipherHexData: [HexCvtr hexFromData: cipherData]];
    
    NSLog(@"trackData = %@", [trackData debugDescription]);
    
    [self.currentReader setTrackData: trackData];
    
    CCheckRequestModel *request = [CCheckRequestModel requestWithReader: self.currentReader];
    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendCCheckRequest: request
                                       withCompletion:^(CCheckResponseModel *model, NSError *error) {
                                           NSLog(@" response = %@", [model debugDescription]);
                                           NSLog(@"stop!!!");
                                       }];
}

- (IBAction)testCrypto:(id)sender
{
    //*init
    NSString *key = nil;
    NSString *sign = nil;
    NSData *cipherData = nil;
    NSData *decryptData = nil;
    CryptoController *crp = [CryptoController sharedInstance];
    
    //Transport key
    self.devInitData = [InitializationData demoData];
    NSLog(@"devInitData = %@", [self.devInitData debugDescription]);
    
    NSString *hexTransportKey = [crp calcTransportKey: self.devInitData];
    
    [self.keyChain setOtp: self.devInitData.otp];
    [self.keyChain setTransportKey: hexTransportKey];
    NSLog(@"keyChain = %@", [self.keyChain debugDescription]);
    
    //AES
    NSString *plainData = DEMO_TRACK_DATA;
    NSLog(@"plain data = %@", plainData);
    
    //*go
    NSLog(@"\n\n ________ AES128 ________ \n\n");
    
    key = DEMO_AES128_KEY;
    NSLog(@"key128 = %@", key);
    cipherData = [crp aes128EncryptHexData: plainData
                                withHexKey: key];
    NSLog(@"cipherData128 = %@", [HexCvtr hexFromData: cipherData]);

    decryptData = [crp aes128DecryptHexData: [HexCvtr hexFromData: cipherData]
                                 withHexKey: key];
    NSLog(@"decryptData128 = %@", [HexCvtr hexFromData: decryptData]);
    
    NSLog(@"\n\n ________ AES256 ________ \n\n");
    
    key = DEMO_AES256_KEY;
    NSLog(@"key256 = %@", key);
    cipherData = [crp aes256EncryptHexData: plainData
                                withHexKey: key];
    NSLog(@"cipherData256 = %@", [HexCvtr hexFromData: cipherData]);
    
    decryptData = [crp aes256DecryptHexData: [HexCvtr hexFromData: cipherData]
                                 withHexKey: key];
    NSLog(@"decryptData256 = %@", [HexCvtr hexFromData: decryptData]);
    
    NSLog(@"\n\n ________ подпись JSON (алгоритм 1) ________ \n\n");
    sign = [crp calcSignature1: [HexCvtr dataFromHex: plainData]];
    NSLog(@"%@", sign);
    
    NSLog(@"\n\n ________ подпись JSON (алгоритм 2) ________ \n\n");
    sign = [crp calcSignature2: [HexCvtr dataFromHex: plainData]];
    NSLog(@"%@", sign);
}

#pragma mark - ReaderControllerDelegate

- (void)readerController:(ReaderController *)controller didReceiveData:(CardReaderData *)data
{
    NSLog(@"%@: data => %@", CURRENT_METHOD, [data debugDescription]);
}


@end
