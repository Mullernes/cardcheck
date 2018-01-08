//
//  ViewController.m
//  CardCheck
//
//  Created by itnesPro on 12/20/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "ViewController.h"

#import "DevInitData.h"
#import "ReaderController.h"

#import "NSData+AES.h"

@interface ViewController ()

@property (nonatomic, strong) DevInitData *devInitData;
@property (nonatomic, strong) CardReaderData *currentReader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    CryptoController *crp = [CryptoController sharedInstance];
    NSString *key = @"b745ec0fdf5c9e94db10";

    //NSInteger value1 = [crp hotpWithText: [request jsonString] andSecret: key];
    //NSInteger value2 = [crp hotpWithData: [request jsonData] andSecret: key];
    //NSNumber *value3 = [crp hotpWithValue: 1514636766 andSecret: key];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CardReaderData *)currentReader {
    if (_currentReader == nil) {
        _currentReader = [CardReaderData demoData];
    }
    
    return _currentReader;
}

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
                                             weakSelf.devInitData = [DevInitData new];
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
                                    andHexKey: self.currentReader.customID];
    [self.devInitData setupWithCalculatedOtp: [value unsignedIntegerValue]];

    NSLog(@"otp = %lu", value.unsignedIntegerValue);
}

- (IBAction)initialization:(id)sender
{
    //NSUInteger typedOtp = [self.typedOtp.text integerValue];
    NSUInteger typedOtp = self.devInitData.otp;
    if (self.devInitData.otp == typedOtp)
    {
        DevInitRequestModel *request = [DevInitRequestModel requestWithData: self.devInitData
                                                                  andReader: self.currentReader];
        __weak ViewController *weakSelf = self;
        [[APIController sharedInstance] sendDevInitRequest: request
                                            withCompletion:^(DevInitResponseModel *model, NSError *error) {
                                                if (model.isCorrect)
                                                {
                                                    [weakSelf.devInitData setupWithDevInitResponse: model];
                                                    
                                                    NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                                }
                                                else {
                                                    NSLog(@"response = %@", model);
                                                }
                                            }];
    }
}

- (IBAction)calcKeys:(id)sender
{
    if (DEMO_MODE) {
        self.devInitData = [[DevInitData alloc] initDemoData];
    }
    else {
        CryptoController *crp = [CryptoController sharedInstance];
        NSString *hexTransportKey = [crp calcTransportKey: self.devInitData];
        NSLog(@"transportKey = %@", hexTransportKey);
        
        NSData *appKeys = [crp aes128DecryptHexData: [self.devInitData cipherAppKeys]
                                         withHexKey: hexTransportKey];
        NSLog(@"appKeys = %@", [HexCvtr hexFromData: appKeys]);
        
        NSData *appDataKey = [appKeys subdataWithRange: NSMakeRange(0, 32)];
        NSData *appCommKey = [appKeys subdataWithRange: NSMakeRange(32, 32)];
        
        NSLog(@"appDataKey = %@", [HexCvtr hexFromData: appDataKey]);
        NSLog(@"appCommKey = %@", [HexCvtr hexFromData: appCommKey]);
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
