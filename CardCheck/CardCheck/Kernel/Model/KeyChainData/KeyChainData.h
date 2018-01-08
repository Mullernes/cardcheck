//
//  KeyChainData.h
//  CardCheck
//
//  Created by itnesPro on 1/8/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface KeyChainData : KLBaseModel

@property (nonatomic, strong) NSString *appDataKey;
/*
 32 байта, AES256 ключ для шифрования чувствительных данных
 в запросах проверки карт и завершения проверки карт;
 */

@property (nonatomic, strong) NSString *appCommKey;
/*
 AppCommKey: 32 байта, вторая компонента коммуникационного ключа;
 */

@property (nonatomic, strong, readonly) NSString *commKey;
/*
 CommKey: 42 байта, коммуникационный ключ = concatenate(CustomId,AppCommKey),
 служит для подписи сообщений проверки карт и завершения проверки карт;
 */

@property (nonatomic, strong) NSString *customId;
/*
 CustomId: 10 байт, первая компонента коммуникационного ключа
 (доступна только программно, храниться в ридере);
 */

@property (nonatomic, strong) NSString *transportKey;
/*
 TransportKey: 16 байт,
 AES128 ключ для шифрования ключей приложения,
 */

@property (nonatomic) long otp;

/*
 одноразовый пароль / OTP: шестизначное число
 */

#pragma mark - Init
+ (instancetype)sharedInstance;

@end

