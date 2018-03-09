

#import "JSONKit.h"

@implementation NSData (JSONKitDeserializing)

- (id)objectsFromJSONData
{
    if ([self isKindOfClass: [NSData class]] == NO) return nil;
    
    NSError * err;
    id response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: self options: NSJSONReadingMutableContainers error: &err];
    
    return response;
}

@end

@implementation NSString (JSONKitDeserializing)

- (id)objectsFromJSONString
{
    if ([self isKindOfClass: [NSString class]] == NO) return nil;
    
    id response = [[self dataUsingEncoding: NSUTF8StringEncoding] objectsFromJSONData];
    
    return response;
}

@end

@implementation NSDictionary (JSONKitSerializing)

- (NSData *)JSONData
{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: self options: 0 error: &err];
    
    return jsonData;
}

- (NSString *)JSONString
{
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options: 0 error: &err];
    NSString *myString = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];
    
    return myString;
}

@end

