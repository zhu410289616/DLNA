//
//  RHUPnPDevice.m
//  DLNAClient
//
//  Created by zhuruhong on 2017/10/16.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHUPnPDevice.h"

@implementation RHServiceModel

@end

@implementation RHUPnPDevice

- (NSString *)urlHeader
{
    if (nil == _urlHeader) {
        _urlHeader = [NSString stringWithFormat:@"%@://%@:%@", _location.scheme, _location.host, _location.port];
    }
    return _urlHeader;
}

- (RHServiceModel *)avTransport
{
    if (nil == _avTransport) {
        _avTransport = [[RHServiceModel alloc] init];
    }
    return _avTransport;
}

- (RHServiceModel *)renderingControl
{
    if (nil == _renderingControl) {
        _renderingControl = [[RHServiceModel alloc] init];
    }
    return _renderingControl;
}

@end
