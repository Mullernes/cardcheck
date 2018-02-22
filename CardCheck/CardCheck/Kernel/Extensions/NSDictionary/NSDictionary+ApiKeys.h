
#import <Foundation/Foundation.h>

@interface NSDictionary (ApiKeys)

#pragma mark - Auth / Init
- (NSNumber *)kAppID;
- (NSNumber *)kRequestID;
- (NSNumber *)kResponseTime;
- (NSNumber *)kResponseCode;
- (NSString *)kAppKeys;

#pragma mark - CCheck
- (NSNumber *)kFakeCard;
- (NSNumber *)kReportID;
- (NSString *)kReportDate;
- (NSNumber *)kImageID;
- (NSNumber *)kImageSize;
- (NSNumber *)kImageCRC32;
- (NSNumber *)numberValueForKey:(NSString *)key;

#pragma mark - CReport
- (NSString *)kCardType;
- (NSString *)kCardTitle;
- (NSString *)kHolderName;
- (NSString *)kIssuerName;
- (NSString *)kTruncatedPan;
- (NSString *)kIssuerCountry;

- (NSArray<NSString *> *)kCardBlackLists;
- (NSArray<NSDictionary*> *)kReportColumns;


@end
