//
//  RHUdpConnection.m
//  Example
//
//  Created by zhuruhong on 2017/10/11.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "RHUdpConnection.h"

@implementation RHUdpConnection

- (instancetype)init
{
    if (self = [super init]) {
        _host = @"232.1.0.2";
        _port = 22345;
        NSString *queueName =  @"com.zrh.socket.queue.1011";
        _socketQueue = dispatch_queue_create([queueName UTF8String], NULL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

#pragma mark - setter & getter

- (void)setBroadcastEnabled:(BOOL)broadcastEnabled
{
    _broadcastEnabled = broadcastEnabled;
    [_udpSocket enableBroadcast:_broadcastEnabled error:nil];
}

#pragma mark - public function

- (void)start
{
    NSError *error = nil;
    if (![_udpSocket bindToPort:_port error:&error]) {
        return;
    }
    
    if (![_udpSocket enableBroadcast:_broadcastEnabled error:&error]) {
        return;
    }
    
    if (_multicastEnabled) {
        if (![_udpSocket joinMulticastGroup:_host error:&error]) {
            return;
        }
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        [_udpSocket close];
        return;
    }
    
    NSLog(@"Udp started on %@:%hu", [_udpSocket localHost], [_udpSocket localPort]);
}

- (void)stop
{
    [_udpSocket pauseReceiving];
    [_udpSocket close];
}

- (void)sendData:(NSData *)data
{
    if (data.length == 0) {
        return;
    }
    
    [self sendData:data toHost:_host port:_port];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port
{
    long tag = clock();
    [self sendData:data toHost:host port:port tag:tag];
}

- (void)sendData:(NSData *)data toHost:(NSString *)host port:(NSInteger)port tag:(long)tag
{
    [_udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (_receiveBlock) {
        NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
        _receiveBlock(data, host);
    }
}

@end
