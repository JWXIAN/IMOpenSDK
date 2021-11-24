//
//  IMOpenServerManager.h
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    
    IMMessageBodyType_New = 1,  /*! 创建会话 */
    IMMessageBodyType_Text,         /*! 文本类型 */
    IMMessageBodyType_Image,        /*! 图片类型 */
    IMMessageBodyType_Voice,        /*! 语音类型 */
    IMMessageBodyType_Video,        /*! 视频类型 */
    IMMessageBodyType_System,       /*! 系统类型 */
    IMMessageBodyType_File,         /*! 文件类型 */
    IMMessageBodyType_Link,         /*! 链接类型 */
    IMMessageBodyType_Face          /*! 人脸识别 */
    
} IMMessageBodyType;

//初始化回调 code 1 成功 -1失败
typedef void(^IMServerManagerBlock)(int code, NSString *message);
//初始化回调 code 1 成功 -1失败
typedef void(^IMSendMessageServerBlock)(int code, NSString *message);

// 回调消息代理
@protocol IMOpenServerManagerDelegate <NSObject>
- (void)reciveMessage:(NSDictionary *)message;
@end

@interface IMOpenServerManager : NSObject

@property (nonatomic, weak) id<IMOpenServerManagerDelegate> delegate;

/**
 *@author GJW 2021年11月11日
 *@初始化在线客服管理类
 */
+ (IMOpenServerManager *)shareInstance;

/**
 *@author GJW 2021年11月11日
 *@初始化
 *@param reqParm 初始化参数
 *@param completionBlock 回调
*/
- (void)initializeServer:(NSMutableDictionary *)reqParm
              completion:(IMServerManagerBlock)completionBlock;

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

@end

