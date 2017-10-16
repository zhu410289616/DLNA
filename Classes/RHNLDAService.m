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
#import "RHUPnPDevice.h"

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

@property (nonatomic, strong) dispatch_queue_t queue;
/**
 * key:         usn(uuid) string
 * value:       device
 */
@property (nonatomic, strong) NSMutableDictionary *deviceDic;
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

- (instancetype)init
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.zrh.dlna.client", DISPATCH_QUEUE_SERIAL);
        _deviceDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)ssdp
{
    RHSSDPSearchModel *search = [[RHSSDPSearchModel alloc] init];
    
    if (nil == _udpConnection) {
        _udpConnection = [[RHUdpConnection alloc] init];
        _udpConnection.host = search.address;
        _udpConnection.port = search.port;
        
        _udpConnection.multicastEnabled = YES;
        __weak typeof(self) weakSelf = self;
        _udpConnection.receiveBlock = ^(NSData *receiveData, NSString *fromHost) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dealReceiveData:receiveData fromHost:fromHost];
        };
        [_udpConnection start];
    }
    [_deviceDic removeAllObjects];//清空历史设备记录
    [_udpConnection sendData:[search dataWithModel]];
}

- (void)dealReceiveData:(NSData *)receiveData fromHost:(NSString *)fromHost
{
    NSString *msg = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
    NSLog(@">>>>>>>>>>> fromHost: %@", fromHost);
//    NSLog(@"RECV: %@", msg);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(_queue, ^{
        if ([msg hasPrefix:@"HTTP/1.1"]) {
            [weakSelf dealSearchWithMsg:msg];
        } else if ([msg hasPrefix:@"NOTIFY"]) {
            [weakSelf dealNotifyWithMsg:msg];
        }
    });
}

- (void)dealSearchWithMsg:(NSString *)msg
{
    NSString *location = headerValue(@"LOCATION:", msg);
    NSString *usn = headerValue(@"USN:", msg);
    __weak typeof(self) weakSelf = self;
    [self getDeviceWithLocation:location USN:usn success:^(RHUPnPDevice *device) {
        NSLog(@"success: %@", device.src);
        [weakSelf addDeviceWithKey:usn device:device];
    } failure:^(NSError *error) {
        NSLog(@"failure: %@", error);
    }];
}

- (void)dealNotifyWithMsg:(NSString *)msg
{
    NSString *serviceType = headerValue(@"NT:", msg);
    NSString *location = headerValue(@"LOCATION:", msg);
    NSString *usn = headerValue(@"USN:", msg);
    NSString *ssdp = [headerValue(@"NTS:", msg) lowercaseString];
    
    NSLog(@"serviceType: %@", serviceType);
    NSLog(@"location: %@", location);
    NSLog(@"usn: %@", usn);
    NSLog(@"ssdp: %@", ssdp);
    
    if ([ssdp isEqualToString:@"ssdp:alive"]) {
        if (nil == [self deviceWithKey:usn]) {
            __weak typeof(self) weakSelf = self;
            [self getDeviceWithLocation:location USN:usn success:^(RHUPnPDevice *device) {
                NSLog(@"success: %@", device.src);
                [weakSelf addDeviceWithKey:usn device:device];
            } failure:^(NSError *error) {
                NSLog(@"failure: %@", error);
            }];
        }
    } else if ([ssdp isEqualToString:@"ssdp:byebye"]) {
        [self removeDeviceWithKey:usn];
    }
}

- (RHUPnPDevice *)deviceWithKey:(NSString *)key
{
    if (nil == key) {
        return nil;
    }
    return _deviceDic[key];
}

- (void)addDeviceWithKey:(NSString *)key device:(RHUPnPDevice *)device
{
    if (nil == key || nil == device) {
        return;
    }
    _deviceDic[key] = device;
    [self onChange];
}

- (void)removeDeviceWithKey:(NSString *)key
{
    if (nil == key) {
        return;
    }
    _deviceDic[key] = nil;
    [self onChange];
}

- (void)onChange
{
    NSLog(@"devices: %@", _deviceDic);
}

- (void)getDeviceWithLocation:(NSString *)location USN:(NSString *)usn success:(void(^)(RHUPnPDevice *device))successBlock failure:(void(^)(NSError *error))failureBlock
{
    if (location.length == 0) {
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:[location lowercaseString]];
    NSLog(@"URL: %@", URL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    request.HTTPMethod = @"GET";
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || nil == response || nil == data) {
            failureBlock(error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            RHUPnPDevice *device = [[RHUPnPDevice alloc] init];
            device.location = URL;
            device.uuid = usn;
            device.src = content;
            successBlock(device);
        } else {
            failureBlock(error);
        }
    }] resume];
}

@end
