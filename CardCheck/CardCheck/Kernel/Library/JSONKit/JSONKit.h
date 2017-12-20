

#import <Foundation/Foundation.h>

@interface NSString (JSONKitDeserializing)

- (NSDictionary *)objectFromJSONString;
@end

@interface NSDictionary (JSONKitSerializing)

- (NSString *)JSONString;
@end