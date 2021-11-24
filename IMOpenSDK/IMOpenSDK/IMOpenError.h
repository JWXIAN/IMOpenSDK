//
//  IMOpenError.h
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    
    IMOpenErrorFailed = 1,                               /*! 一般错误 */
    IMOpenErrorNetworkUnavailable,                       /*! 网络不可用 */
    IMOpenErrorFileUploadImageFailed,                    /*! 上传图片失败 */
    IMOpenErrorFileUploadVoiceFailed,                    /*! 上传语音失败 */
    IMOpenErrorSendMessageFailed,                        /*! 发送消息失败 */
    IMOpenErrorLoginFailed,                              /*! 登录失败 */
    IMOpenErrorNull,                                     /*! 无 */
    
}IMOpenErrorCode;


@interface IMOpenError : NSObject

/*!
 *  错误码
 */
@property (nonatomic) IMOpenErrorCode errorCode;

/*!
 *  错误描述
 */
@property (nonatomic, copy) NSString *errorDescription;


/*!
 *  @author GJW 2021年11月11日
 *  创建错误实例
 *
 *  @param errorDescription  错误描述
 *  @param errorCode         错误码
 *
 *  @result 对象实例
 */
- (instancetype)initErrorWithDescription:(NSString *)errorDescription
                                code:(IMOpenErrorCode)errorCode;

@end

NS_ASSUME_NONNULL_END
