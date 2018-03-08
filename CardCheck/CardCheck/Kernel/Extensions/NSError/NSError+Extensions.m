//
//  NSError+Extensions.m
//  CardCheck
//
//  Created by itnesPro on 1/2/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "NSError+Extensions.h"

@implementation NSError (Extensions)

+ (NSDictionary *)prefixStore
{
    return @{
             @(-1):@"UNKNOWN | неизвестная ошибка",
             @(0):@"Success | успешно выполено",
             @(1):@"SYSTEM_ERROR | ошибка сервера",
             @(2):@"FORMAT_ERROR | неверный формат запроса",
             @(3):@"REPEATED_REQUEST | повторный приём запроса",
             @(4):@"INVALID_SIGN | неверная подпись запроса",
             @(5):@"INVALID_LOGIN | введен неверный логин",
             @(6):@"INVALID_EMAIL | указан неверный e-mail в профиле пользователя",
             @(7):@"BEFORE_SEND_EMAIL | ошибка сервера до отсылки пароля на e-mail",
             @(8):@"CARDREADER_NOT_ASSOCIATED | картридер не привязан к пользователю",
             @(9):@"OTP_GENERATION_ERROR | ошибка генерации пароля",
             @(10):@"SEND_EMAIL_ERROR | ошибка отправки пароля на e-mail",
             @(11):@"INVALID_AUTHENTICATION_REQUEST_ID | неверный идентификатор аутентификации",
             @(12):@"INVALID_AUTHENTICATION_REQUEST | указанная аутентификация не была успешной",
             @(13):@"EXPIRED_AUTHENTICATION_REQUEST | просроченная аутентификация (более 10 минут)",
             @(14):@"WAIT_COMPLETE | отчёт ожидает завершения",
             @(15):@"UPLOAD_ERROR | ошибка загрузки изображения на сервер",
             @(16):@"INVALID_REPORT | неверный идентификатор отчёта или отчёт не ожидает завершения",
             @(17):@"COMPLETED_REPORT | отчёт уже был завершён",
             @(18):@"LAST_TRY_COUNTER_EXHAUSTED | трижды введён неверный пароль"
             };
}

+ (NSString *)prefixWithCode:(NSInteger)code
{
    return [[NSError prefixStore] objectForKey: @(code)];
}

- (NSString *)readableDescription
{
    NSString *string = self.localizedDescription;
    
    if ([self.localizedDescription hasPrefix: @"Prefix:"]) {
        NSRange searchFromRange = [string rangeOfString: @"Prefix:"];
        NSRange searchToRange = [string rangeOfString: @"Method:"];
        
        NSUInteger location = searchFromRange.location+searchFromRange.length;
        NSUInteger length = searchToRange.location - location;
        
        NSString *substring = [string substringWithRange:NSMakeRange(location, length)];
        
        return [[substring componentsSeparatedByString:@" | "] lastObject];
    }
    else {
        return self.localizedDescription;
    }
}

@end
