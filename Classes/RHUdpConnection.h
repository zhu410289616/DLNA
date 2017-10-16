//
//  RHUdpConnection.h
//  Example
//
//  Created by zhuruhong on 2017/10/11.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

typedef void(^RHReceiveBlock)(NSData *receiveData, NSString *fromHost);

@interface RHUdpConnection : NSObject <GCDAsyncUdpSocketDelegate>

@property (nonatomic,   copy) RHReceiveBlock receiveBlock;

/** 是否开启广播 YES-开启，NO-关闭 默认NO */
@property (nonatomic, assign) BOOL broadcastEnabled;
/** 是否加入组播 YES-开启，NO-关闭 默认NO */
@property (nonatomic, assign) BOOL multicastEnabled;

@property (nonatomic,   copy) NSString *host;
@property (nonatomic, assign) NSInteger port;

@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

- (void)start;
- (void)stop;

- (void)sendData:(NSData *)data;
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port;
- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port tag:(long)tag;

@end
