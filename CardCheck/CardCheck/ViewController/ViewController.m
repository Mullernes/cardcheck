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

@property (nonatomic, strong) DevInitData *devInit;

@property (weak, nonatomic) IBOutlet UITextField *requestID;
@property (weak, nonatomic) IBOutlet UITextField *responseTime;
@property (weak, nonatomic) IBOutlet UITextField *calculatedOtp;

- (IBAction)otp:(id)sender;
- (IBAction)auth:(id)sender;

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

- (void)setDevInit:(DevInitData *)devInit
{
    _devInit = devInit;
    
    NSString *respTime = [NSString stringWithFormat:@"%li", _devInit.responseTime];
    [self.responseTime setText: respTime];
    
    NSString *reqID = [NSString stringWithFormat:@"%li", _devInit.requestID];
    [self.requestID setText: reqID];
}

- (IBAction)auth:(id)sender
{
    CardReader *reader = [CardReader demoReader];
    AuthRequestModel *request = [AuthRequestModel requestWithLogin: DEMO_LOGIN
                                                         andReader: reader];

    __weak ViewController *weakSelf = self;
    [[APIController sharedInstance] sendAuthRequest: request
                                     withCompletion:^(AuthResponseModel *model, NSError *error) {
                                         if (model.isCorrect) {
                                             weakSelf.devInit = [[DevInitData alloc] initWithAuthResponse: model];
                                         }
                                         else {
                                             NSLog(@"response = %@", model);
                                         }
                                     }];
}

- (IBAction)otp:(id)sender
{
    CryptoController *crp = [CryptoController sharedInstance];
    NSString *key = @"b745ec0fdf5c9e94db10";
    NSNumber *value = [crp hotpWithValue: (int)self.devInit.responseTime andSecret: key];
    
    [self.calculatedOtp setText: [value stringValue]];
}
@end
