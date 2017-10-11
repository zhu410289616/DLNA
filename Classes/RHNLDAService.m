//
//  RHNLDAService.m
//  Example
//
//  Created by zhuruhong on 2017/10/11.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHNLDAService.h"
#import "RHSSDPSearchModel.h"
#import "RHUdpConnection.h"

static inline NSString *headerValue(NSString *key, NSString *inData)
{
    NSString *theStr = [[NSString stringWithFormat:@"%@", inData] uppercaseString];
    NSRange keyRange = [theStr rangeOfString:key options:NSCaseInsensitiveSearch];
    if (keyRange.length == 0 || keyRange.location == NSNotFound) {
        return @"";
    }
    
    theStr = [theStr substringFromIndex:keyRange.location + keyRange.length];
    
    NSRange enterRange = [theStr rangeOfString:@"\r\n"];
    NSString *value = [theStr substringToIndex:enterRange.location];
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return value;
}

@interface RHNLDAService ()

@property (nonatomic, strong) RHUdpConnection *udpConnection;

@end

@implementation RHNLDAService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)ssdp
{
    RHSSDPSearchModel *search = [[RHSSDPSearchModel alloc] init];
    
    if (nil == _udpConnection) {
        _udpConnection = [[RHUdpConnection alloc] init];
        _udpConnection.host = search.address;
        _udpConnection.port = search.port;
        
        __weak typeof(self) weakSelf = self;
        _udpConnection.receiveBlock = ^(NSData *receiveData, NSString *fromHost) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dealReceiveData:receiveData fromHost:fromHost];
        };
        [_udpConnection start];
    }
    [_udpConnection sendData:[search dataWithModel]];
}

- (void)dealReceiveData:(NSData *)receiveData fromHost:(NSString *)fromHost
{
    NSString *msg = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"fromHost: %@", fromHost);
    NSLog(@"RECV: %@", msg);
    
    if ([msg hasPrefix:@"HTTP/1.1"]) {
        NSString *location = headerValue(@"LOCATION:", msg);
        NSString *usn = headerValue(@"USN:", msg);
        [self getDeviceWithLocation:location USN:usn];
    }
}

- (void)getDeviceWithLocation:(NSString *)location USN:(NSString *)usn
{
    if (location.length == 0) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:location];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    request.HTTPMethod = @"GET";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || nil == response || nil == data) {
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"content: %@", content);
        }
    }] resume];
}

@end
