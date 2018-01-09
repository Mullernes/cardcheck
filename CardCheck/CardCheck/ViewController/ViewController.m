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

@interface ViewController ()

@property (nonatomic, strong) KeyChainData *keyChain;
@property (nonatomic, strong) CardReaderData *currentReader;
@property (nonatomic, strong) InitializationData *devInitData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Base init
    self.keyChain = [KeyChainData demoData];
    self.currentReader = [CardReaderData demoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Working

- (void)completeInitialization
{
    if (DEMO_MODE) {
        self.devInitData = [InitializationData demoData];
    }
    
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

- (IBAction)readerInit:(id)sender {
    ReaderController *reader = [ReaderController sharedInstance];
    [reader initReader];
}

- (IBAction)readerGetIDs:(id)sender {
    ReaderController *reader = [ReaderController sharedInstance];
    [reader getDeviceID];
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
    NSNumber *value = [crp hotpWithValue: self.devInitData.authResponseTime
                                    andHexKey: [[KeyChainData sharedInstance] customId]];
    [self.devInitData setupWithCalculatedOtp: [value unsignedIntegerValue]];

    NSLog(@"otp = %lu", value.unsignedIntegerValue);
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
                                                    
                                                    NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                                }
                                                else {
                                                    NSLog(@"response = %@", model);
                                                }
                                            }];
    }
}

- (IBAction)testAes:(id)sender
{
    CryptoController *crp = [CryptoController sharedInstance];
    
    NSLog(@"input data = %@", DEMO_APP_KEYS);
    NSLog(@"key = %@", DEMO_TRANSPORT_KEY);
    
    NSData *cipherData = [crp aes128EncryptHexData: DEMO_APP_KEYS withHexKey: DEMO_TRANSPORT_KEY];
    NSLog(@"cipherData = %@", [HexCvtr hexFromData: cipherData]);
    
    NSData *plainData = [crp aes128DecryptHexData: DEMO_APP_KEYS withHexKey: DEMO_TRANSPORT_KEY];
    NSLog(@"plainData = %@", [HexCvtr hexFromData: plainData]);
}


@end
