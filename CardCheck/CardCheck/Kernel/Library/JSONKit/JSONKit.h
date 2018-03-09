

#import <Foundation/Foundation.h>

@interface NSData (JSONKitDeserializing)

- (id)objectsFromJSONData;
@end


@interface NSString (JSONKitDeserializing)

- (id)objectsFromJSONString;
@end


@interface NSDictionary (JSONKitSerializing)

- (NSData *)JSONData;
- (NSString *)JSONString;
@end

