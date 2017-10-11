//
//  RHSSDPSearchModel.m
//  Example
//
//  Created by zhuruhong on 2017/10/11.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHSSDPSearchModel.h"

@implementation RHSSDPSearchModel

- (instancetype)init
{
    if (self = [super init]) {
        _address = @"239.255.255.250";
        _port = 1900;
        _MX = 1;
        _ST = @"urn:schemas-upnp-org:service:AVTransport:1";
    }
    return self;
}

- (NSData *)dataWithModel
{
    NSMutableString *searchStr = [[NSMutableString alloc] init];
    [searchStr appendFormat:@"M-SEARCH * HTTP/1.1\r\n"];
    [searchStr appendFormat:@"HOST: %@:%d\r\n", _address, _port];
    [searchStr appendFormat:@"MAN: \"ssdp:discover\"\r\n"];
    [searchStr appendFormat:@"MX: %d\r\n", _MX];
    [searchStr appendFormat:@"ST: %@\r\n", _ST];
    [searchStr appendFormat:@"USER-AGENT: iOS UPnP/1.1 Tiaooo/1.0\r\n\r\n"];
    return [searchStr dataUsingEncoding:NSUTF8StringEncoding];
}

@end
