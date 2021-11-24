//
//  IMOpenServerManager.m
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import "IMOpenServerManager.h"
#import "IMOpenCoreManager.h"

@interface IMOpenServerManager()

@end
@implementation IMOpenServerManager{
    IMServerManagerBlock _iMServerManagerBlock;
}

/**
 *@author  GJW 2021年05月20日
 *@初始化视频客服管理类
 */
+ (IMOpenServerManager *)shareInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


/**
 *@author GJW 2021年05月20日
 *@初始化
 *@param reqParm 初始化参数
 *@param completionBlock 回调
*/
- (void)initializeServer:(NSMutableDictionary *)reqParm
              completion:(IMServerManagerBlock)completionBlock
{
    _iMServerManagerBlock = completionBlock;

    // 连接xmpp
    [self xmppLogin:reqParm];
    
    // 收到消息
    [self reciveMessage];

    
}

#pragma mark - 建立连接
- (void)xmppLogin:(NSMutableDictionary *)reqParm{
    // server
    [IMOpenCoreManager shareInstance].xmppDomain = @"";
    [IMOpenCoreManager shareInstance].xmppHost = @"";
    [IMOpenCoreManager shareInstance].xmppPort = 5222;
    [IMOpenCoreManager shareInstance].xmppSendTo = @"127.0.0.1@test";
    
    [[IMOpenCoreManager shareInstance] xmppLoginWithInitCompletion:^(int isSuccess, IMOpenError *error) {
        NSLog(@"连接状态 %d", isSuccess);
    } loginCompletion:^(int isSuccess, IMOpenError *error) {
        NSLog(@"登录状态 %d", isSuccess);
    }];
}

#pragma mark - 收到消息

- (void)reciveMessage{
    // 收到消息
    [[IMOpenCoreManager shareInstance] didReciveDicMessage:^(NSDictionary *message) {
        NSLog(@"IMOpenSDK | 收到消息：%@", message);
        if (self.delegate&&[self.delegate respondsToSelector:@selector(reciveMessage:)]) {
            [self.delegate reciveMessage:message];
        }
    }];
}

#pragma mark - 发送消息
/*!
 * @author GJW 2021年05月20日
 * @发送消息
 *
 *  @param body                             消息
 *  @param messageType              消息类型
 *  @param completionBlock     回调结果
 *
 *  @since 0.1
 */
- (void)sendMessageWithBody:(NSString *)body
                  messageType:(IMMessageBodyType)messageType
                   completion:(IMSendMessageServerBlock)completionBlock;
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // 发送消息
    [[IMOpenCoreManager shareInstance] sendDicMessage:dic completion:^(int isSuccess, IMOpenError *error) {
        NSLog(@"IMOpenSDK | 发送消息状态：%d", isSuccess);
        
        if (completionBlock) {
            completionBlock(isSuccess, error.errorDescription);
        }
    }];
}

@end
