

#import "JSONKit.h"

@implementation NSString (JSONKitDeserializing)

- (NSDictionary *)objectFromJSONString
{
    NSError * err;
    NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [self dataUsingEncoding:NSUTF8StringEncoding]
                                                                             options: NSJSONReadingMutableContainers error:&err];
    return response;
}

@end

@implementation NSDictionary (JSONKitSerializing)

- (NSData *)JSONData
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: self options: 0 error: nil];
    
    return jsonData;
}

- (NSString *)JSONString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options: 0 error: nil];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];
    
    return myString;
}

@end
