//
//  IMOpenCoreManager.h
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import "IMOpenError.h"

typedef void(^DidReciveDicMessageBlock)(NSDictionary *message); // 接收到新消息
typedef void(^DidSendMessageBlock)(int isSuccess, IMOpenError *error); // 发送消息
typedef void(^DidInitBlock)(int isSuccess, IMOpenError *error); // 初始化状态
typedef void(^DidLoginBlock)(int isSuccess, IMOpenError *error); // 登录状态

@interface IMOpenCoreManager : NSObject

@property (nonatomic, strong) NSString *xmppDomain;
@property (nonatomic, strong) NSString *xmppHost;
@property (nonatomic, assign) int xmppPort;
@property (nonatomic, assign) NSString *xmppSendTo; // 接受者

@property (nonatomic, strong) NSString *userName;   //xmpp用户名
@property (nonatomic, strong) NSString *password;   //xmpp密码


/*!
 *  @author GJW 2021年11月11日
 *  @获取 SDK 实例
 *
 *  @since 1.0
 */
+ (instancetype)shareInstance;

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
                    loginCompletion:(DidLoginBlock)loginCompletion;

/*!
 *  @author GJW 2021年11月11日
 *  @收到消息
 *
 *  @param completionBlock 回调结果
 *
 *  @since 1.0
 */
- (void)didReciveDicMessage:(DidReciveDicMessageBlock)completionBlock;


/*!
 *  @author GJW 2021年11月11日
 *  @发送消息
 *
 *  @param message           消息json
 *  @param completionBlock   回调结果
 *
 *  @since 1.0
 */
- (void)sendDicMessage:(NSDictionary *)message
             completion:(DidSendMessageBlock)completionBlock;


@end
