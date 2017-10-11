//
//  RHSSDPSearchModel.h
//  Example
//
//  Created by zhuruhong on 2017/10/11.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHSSDPSearchModel : NSObject

/**
 * 设置为协议保留多播地址和端口
 * 必须是：239.255.255.250:1900（IPv4）或FF0x::C(IPv6
 */
@property (nonatomic, strong) NSString *address;

/**
 * 设置为协议保留多播端口，see address
 */
@property (nonatomic, assign) UInt16 port;

/**
 * 设置设备响应最长等待时间
 * 设备响应在0和这个值之间随机选择响应延迟的值。这样可以为控制点响应平衡网络负载。
 */
@property (nonatomic, assign) UInt16 MX;

/**
 * 设置服务查询的目标，它必须是下面的类型：
 * ssdp:all  搜索所有设备和服务
 * upnp:rootdevice  仅搜索网络中的根设备
 * uuid:device-UUID  查询UUID标识的设备
 * urn:schemas-upnp-org:device:device-Type:version  查询device-Type字段指定的设备类型，设备类型和版本由UPNP组织定义。
 * urn:schemas-upnp-org:service:service-Type:version  查询service-Type字段指定的服务类型，服务类型和版本由UPNP组织定义
 */
@property (nonatomic, strong) NSString *ST;

- (NSData *)dataWithModel;

@end
