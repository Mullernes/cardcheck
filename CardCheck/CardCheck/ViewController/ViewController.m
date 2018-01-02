//
//  ViewController.m
//  CardCheck
//
//  Created by itnesPro on 12/20/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "ViewController.h"
#import "DevInitData.h"

@interface ViewController ()

@property (nonatomic, strong) DevInitData *devInitData;
@property (nonatomic, strong) CardReader *currentReader;

@property (weak, nonatomic) IBOutlet UITextField *requestID;
@property (weak, nonatomic) IBOutlet UITextField *responseTime;
@property (weak, nonatomic) IBOutlet UITextField *calculatedOtp;

@property (weak, nonatomic) IBOutlet UITextField *typedOtp;

- (IBAction)otp:(id)sender;
- (IBAction)auth:(id)sender;
- (IBAction)initialization:(id)sender;

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

- (CardReader *)currentReader {
    if (_currentReader == nil) {
        _currentReader = [CardReader demoReader];
    }
    
    return _currentReader;
}

- (void)setDevInitData:(DevInitData *)devInitData
{
    _devInitData = devInitData;
    
    NSString *reqID = [NSString stringWithFormat:@"%li", _devInitData.authRequestID];
    [self.requestID setText: reqID];
    
    NSString *respTime = [NSString stringWithFormat:@"%lli", _devInitData.authResponseTime];
    [self.responseTime setText: respTime];
}

- (IBAction)auth:(id)sender
{
    AuthRequestModel *request = [AuthRequestModel requestWithLogin: DEMO_LOGIN
                                                         andReader: self.currentReader];
    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendAuthRequest: request
                                     withCompletion:^(AuthResponseModel *model, NSError *error) {
                                         if (model.isCorrect) {
                                             DevInitData *data = [DevInitData new];
                                             [data setupWithAuthResponse: model];
                                             [weakSelf setDevInitData: data];
                                             
                                             NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                         }
                                         else {
                                             NSLog(@"response = %@", model);
                                         }
                                     }];
}

- (IBAction)otp:(id)sender
{
    CryptoController *crp = [CryptoController sharedInstance];
    NSNumber *value = [crp hotpWithValue: self.devInitData.authResponseTime
                               andSecret: DEMO_CUSTOM_ID];
    [self.devInitData setCalcOtp: [value unsignedIntegerValue]];

    [self.calculatedOtp setText: [NSString stringWithFormat:@"%lu", (unsigned long)self.devInitData.calcOtp]];
}

- (IBAction)initialization:(id)sender
{
    //NSUInteger typedOtp = [self.typedOtp.text integerValue];
    NSUInteger typedOtp = self.devInitData.calcOtp;
    if (self.devInitData.calcOtp == typedOtp)
    {
        DevInitRequestModel *request = [DevInitRequestModel requestWithData: self.devInitData
                                                                  andReader: self.currentReader];
        __weak ViewController *weakSelf = self;
        [[APIController sharedInstance] sendDevInitRequest: request
                                            withCompletion:^(DevInitResponseModel *model, NSError *error) {
                                                if (model.isCorrect) {
                                                    [weakSelf.devInitData setupWithDevInitResponse: model];
                                                    
                                                    NSLog(@"devInit = %@", [weakSelf.devInitData debugDescription]);
                                                }
                                                else {
                                                    NSLog(@"response = %@", model);
                                                }
                                            }];
    }
}
@end
