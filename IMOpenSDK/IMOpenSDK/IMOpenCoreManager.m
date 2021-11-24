//
//  IMOpenCoreManager.m
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import "IMOpenCoreManager.h"
#import "XMPPFramework.h"
#import "IMOpenError.h"

@interface IMOpenCoreManager ()<XMPPStreamDelegate, XMPPReconnectDelegate>

@property (nonatomic, strong) XMPPStream *xmppStream;

///// 心跳检测
//@property (nonatomic, strong) XMPPAutoPing *autoPing;

/// 自动重连
@property (nonatomic, strong) XMPPReconnect *reconnect;
@end

@implementation IMOpenCoreManager{
    NSError *_xmppError;
    DidReciveDicMessageBlock     _didReciveDicMessageBlock;
    DidSendMessageBlock          _didSendMessageBlock;
    DidInitBlock                  _didInitBlock;
    DidLoginBlock                 _didLoginBlock;
}

// 实例化SDK
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    
    static IMOpenCoreManager *coreManager = nil;
    
    dispatch_once(&onceToken, ^{
        coreManager = [[IMOpenCoreManager alloc] init];
    });
    return coreManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _xmppStream = [[XMPPStream alloc] init];
        _xmppStream.hostName = @"172.21.0.13";
        _xmppStream.hostPort = 5222;
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 添加心跳检测模块
//        self.autoPing = [[XMPPAutoPing alloc] init];    // 发送的是一个 stream:ping，对方如果想表示自己是活跃的，应该返回一个 pong
//        [self.autoPing activate:self.xmppStream];           // 激活
//        [self.autoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
//        self.autoPing.pingInterval = 1000;              // 定时发送 ping 时间
//        self.autoPing.respondsToQueries = YES;          // 不仅仅是服务器来得响应，如果是普通的用户，一样会响应
//        self.autoPing.targetJID = [XMPPJID jidWithString:HOST_DOMAIN];      // 设置 ping 目标服务器
        // 如果为 nil，则监听 stream 当前连接上的那个服务器
        
        // 添加自动重连模块
        self.reconnect = [[XMPPReconnect alloc] init];
        [self.reconnect activate:self.xmppStream];          // 激活
        [self.reconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.reconnect.autoReconnect = YES;             // 设置是否自动重新连接
    }
    return self;
}


/*!
 *  @author GJW 2021年11月11日
 *  @登录IM
 *
 *  @param initCompletion        初始化回调结果
 *  @param loginCompletion        登录回调结果
 *
 *  @since 1.0
 */
- (void)xmppLoginWithInitCompletion:(DidInitBlock)initCompletion
                    loginCompletion:(DidLoginBlock)loginCompletion
{
    _didInitBlock = initCompletion;
    _didLoginBlock = loginCompletion;
    
    if (_xmppStream) {
        
        _xmppStream.hostName = [IMOpenCoreManager shareInstance].xmppHost;
        _xmppStream.hostPort = [IMOpenCoreManager shareInstance].xmppPort;
        
        // 与服务器建立链接，自定义方法
        if ([_xmppStream isConnected]) {
            [self disconnectWithServer];
        }
        
        NSString *strRandom = @"";
        for(int i=0; i<10; i++)
        {
            strRandom = [strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
        }
        XMPPJID *myID = [XMPPJID jidWithUser:[IMOpenCoreManager shareInstance].userName domain:[IMOpenCoreManager shareInstance].xmppDomain resource:[NSString stringWithFormat:@"iOS%@", strRandom]];
        [_xmppStream setMyJID:myID];
        
        // 进行连接
        NSError *error = nil;
        [_xmppStream connectWithTimeout:10.0 error:&error];
        if (error) {
            NSLog(@"IMOpenSDK | %@", error);
        }
    } else {
        NSLog(@"IMOpenSDK | 账号不存在");
    }
}

#pragma mark - 收到消息回调
- (void)didReciveDicMessage:(DidReciveDicMessageBlock)completionBlock {
    _didReciveDicMessageBlock = completionBlock;
}


#pragma mark XMPPStreamDelegate

/// 与服务器连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    
    NSLog(@"IMOpenSDK | 连接成功");
    

    if (_didInitBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"连接成功" code:IMOpenErrorNull];
        _didInitBlock(1, aError);
    }
    
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:[IMOpenCoreManager shareInstance].password error:&error];
    if (error) {
        NSLog(@"IMOpenSDK | 验证失败 %@", error.description);
    }
}

// 与服务器连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    
    NSLog(@"IMOpenSDK | 连接服务器超时，请检查网络链接后再试！");
    if (_didInitBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"连接超时" code:IMOpenErrorNetworkUnavailable];
        _didInitBlock(-1, aError);
    }
}

// 与服务器断开链接，用户注销，自定义方法
- (void)disconnectWithServer {
    // 断开链接
    [_xmppStream disconnect];
}

#pragma mark - XMPPStreamDelegate 登录
// 登录成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    NSLog(@"IMOpenSDK | 登录成功");
    // 设置用户在线状态，如果没有添加，别人给你发的消息服务器默认为离线状态，是不会给你发送的
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [_xmppStream sendElement:presence];
    
    if (_didLoginBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"登录成功" code:IMOpenErrorNull];
        _didLoginBlock(1, aError);
    }
}

/// 登录失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    
    NSLog(@"IMOpenSDK | 登录失败 %@", error.description);

    if (_didLoginBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"登录失败" code:IMOpenErrorLoginFailed];
        _didLoginBlock(-1, aError);
    }
}


- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    // 设置用户下线状态
    XMPPPresence *presene = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presene];
}


#pragma mark - 发送消息

- (void)sendDicMessage:(NSDictionary *)message completion:(DidSendMessageBlock)completionBlock{
    _didSendMessageBlock = completionBlock;
    
    [self sendXMPPMessage:message];
}

// 发送消息
- (void)sendXMPPMessage:(NSDictionary *)message {
    
    // 设置消息接收者
    NSString *domainString = [IMOpenCoreManager shareInstance].xmppSendTo;

    // 构建消息
    NSXMLElement *msg = [NSXMLElement elementWithName:@"message"];
    [msg addAttributeWithName:@"type" stringValue:@"chat"];
    [msg addAttributeWithName:@"to" stringValue:domainString];
    [msg addAttributeWithName:@"from" stringValue:_xmppStream.myJID.full];
    [msg addAttributeWithName:@"id" stringValue:[self getUDID]];
    // 设置文本消息内容
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
//
    [body setStringValue:[self convertToJsonData:message]];

    [msg addChild:body];
    
    NSLog(@"%@", msg);
    // 发送
    [_xmppStream sendElement:msg];
}

// 接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if (message) {
        NSString *msg = [[message elementForName:@"body"] stringValue];
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSString *to = [[message attributeForName:@"to"] stringValue];
        
        NSData *jsonData = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        // 收到消息
        if (_didReciveDicMessageBlock) {
            _didReciveDicMessageBlock(dic);
        }
    }
}


// 在发送消息成功后，会回调此代理方法
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"%@", message);
    if (_didSendMessageBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"发送消息成功" code:IMOpenErrorNull];
        _didSendMessageBlock(1, aError);
    }
}

// 在发送消息失败后，会回调此代理方法
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    if (_didSendMessageBlock) {
        IMOpenError *aError = [[IMOpenError alloc] initErrorWithDescription:@"发送消息失败" code:IMOpenErrorSendMessageFailed];
        _didSendMessageBlock(-1, aError);
    }
}

#pragma mark - XMPPAutoPingDelegate 协议方法  // 添加心跳检测模块

///// 已经发送 ping
//- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender {
//
//    NSLog(@"IMOpenSDK | AutoPingDidSendPing");
//}
//
///// 接收到 pong
//- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
//
//    NSLog(@"IMOpenSDK | AutoPingDidReceivePong");
//}
//
///// ping 超时
//- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
//
//    NSLog(@"IMOpenSDK | AutoPingDidTimeout");
//}


#pragma mark - XMPPReconnectDelegate 协议方法 自动重连模块

/// 设置是否自动重新连接
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    
    return YES;
}

/// 意外断开连接
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"IMOpenSDK | didDetectAccidentalDisconnect");
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;

    if (!jsonData) {
        NSLog(@"%@",error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}


- (NSString*)getUDID
{
    NSString *str = [[NSUUID UUID] UUIDString];
    NSString *str2 = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return str2;
}

@end
