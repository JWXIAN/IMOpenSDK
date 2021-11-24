//
//  IMOpenError.m
//  IMOpenSDK
//
//  Created by GJW on 2021/11/16.
//

#import "IMOpenError.h"

@implementation IMOpenError

/*!
 *  创建错误实例
 *
 *  @param errorDescription  错误描述
 *  @param errorCode         错误码
 *
 *  @result 对象实例
 */
- (instancetype)initErrorWithDescription:(NSString *)errorDescription
                                code:(IMOpenErrorCode)errorCode
{
    self = [super init];
    
    if (self) {
        _errorDescription = errorDescription;
        _errorCode = errorCode;
    }
    return self;
}

@end
