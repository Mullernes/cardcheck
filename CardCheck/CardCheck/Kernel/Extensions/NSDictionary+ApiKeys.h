
#import <Foundation/Foundation.h>

@interface NSDictionary (ApiKeys)

#pragma mark - Decimal
- (NSNumber *)kAppID;
- (NSNumber *)kRequestID;
- (NSNumber *)kResponseTime;
- (NSNumber *)kResponseCode;

#pragma mark - String
- (NSString *)kAppKeys;

@end
