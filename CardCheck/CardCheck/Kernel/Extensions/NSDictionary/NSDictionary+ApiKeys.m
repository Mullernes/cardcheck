
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

- (NSNumber *)kImageID
{
    return [self numberValueForKey: @"image_id"];
}

- (NSNumber *)kImageSize
{
    return [self numberValueForKey: @"image_size"];
}

- (NSNumber *)kImageCRC32
{
    return [self numberValueForKey: @"image_crc32"];
}

- (NSString *)kAppKeys
{
    return [self valueForKey: @"app_keys"];
}

#pragma mark - CCheck

- (NSNumber *)kReportID
{
    return [self numberValueForKey: @"report_id"];
}

- (NSNumber *)kFakeCard
{
    return [self numberValueForKey: @"fake_card"];
}

- (NSNumber *)numberValueForKey:(NSString *)key
{
    id value = [self valueForKey: key];
    if ([value isKindOfClass: [NSNull class]]) {
        return nil;
    }
    
    return value;
}

- (NSString *)kReportDate
{
    return [self valueForKey: @"report_datetime"];
}

#pragma mark - CReport

- (NSString *)kCardType
{
    return [self valueForKey: @"card_type"];
}

- (NSString *)kHolderName
{
    return [self valueForKey: @"cardholder_name"];
}

- (NSString *)kIssuerCountry
{
    return [self valueForKey: @"issuer_country"];
}

- (NSString *)kIssuerName
{
    return [self valueForKey: @"issuer_name"];
}

- (NSString *)kCardTitle
{
    return [self valueForKey: @"title"];
}

- (NSString *)kTruncatedPan
{
    return [self valueForKey: @"truncated_pan"];
}

- (NSArray<NSString *> *)kCardBlackLists
{
    return [self valueForKey: @"in_blacklists"];
}

- (NSArray<NSDictionary*> *)kReportColumns
{
    return [self valueForKey: @"report_columns"];
}

@end
