//
//  RHUPnPDevice.h
//  DLNAClient
//
//  Created by zhuruhong on 2017/10/16.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHServiceModel : NSObject

@property (nonatomic,   copy) NSString *serviceType;
@property (nonatomic,   copy) NSString *serviceId;
@property (nonatomic,   copy) NSString *controlURL;
@property (nonatomic,   copy) NSString *eventSubURL;
@property (nonatomic,   copy) NSString *SCPDURL;

@end

@interface RHUPnPDevice : NSObject

/** 源数据 */
@property (nonatomic,   copy) NSString *src;

@property (nonatomic,   copy) NSString *uuid;
@property (nonatomic, strong) NSURL *location;
@property (nonatomic,   copy) NSString *urlHeader;

@property (nonatomic,   copy) NSString *friendlyName;
@property (nonatomic,   copy) NSString *modelName;

@property (nonatomic, strong) RHServiceModel *avTransport;
@property (nonatomic, strong) RHServiceModel *renderingControl;

@end
