//
//  ViewController.m
//  CardCheck
//
//  Created by itnesPro on 12/20/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CardReader *reader = [CardReader demoReader];
    AuthRequestModel *request = [AuthRequestModel modelWithLogin: DEMO_LOGIN
                                                       andReader: reader];
  
    /*
    CryptoController *crp = [CryptoController sharedInstance];
    NSString *key = @"b745ec0fdf5c9e94db10";

    NSInteger value1 = [crp hotpWithText: [request jsonString] andSecret: key];
    NSInteger value2 = [crp hotpWithData: [request jsonData] andSecret: key];
    
    NSLog(@"");
     */
    
    [[APIController sharedInstance] sendAuthRequest: request
                                     withCompletion:^(AuthResponseModel *model, NSError *error) {
                                         NSLog(@"response - %@", model);
                                         if (model.isCorrect == NO) {
                                             NSLog(@"");
                                         }
                                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
