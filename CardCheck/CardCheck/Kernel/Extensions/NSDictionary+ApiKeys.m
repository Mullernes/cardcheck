
#import "NSDictionary+ApiKeys.h"

@implementation NSDictionary (ApiKeys)

#pragma mark - Decimal

- (NSNumber *)kAppID
{
    return [self numberValueForKey: @"app_id"];
}

- (NSNumber *)kRequestID
{
    return [self numberValueForKey: @"auth_req_id"];
}

- (NSNumber *)kResponseTime
{
    return [self numberValueForKey: @"time"];
}

- (NSNumber *)kResponseCode
{
    return [self numberValueForKey: @"code"];
}

- (NSNumber *)numberValueForKey:(NSString *)key
{
    id value = [self valueForKey: key];
    if ([value isKindOfClass: [NSNull class]]) {
        return nil;
    }
    
    return value;
}

#pragma mark - String
- (NSString *)kAppKeys
{
    return [self valueForKey: @"app_keys"];
}

@end
