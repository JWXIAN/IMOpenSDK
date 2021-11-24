//
//  ViewController.m
//  IMOpenSDKExample
//
//  Created by GJW on 2021/11/18.
//

#import "ViewController.h"
#import <IMOpenSDK/IMOpenServerManager.h>

@interface ViewController ()<IMOpenServerManagerDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initServer];
}

#pragma mark - 初始化
- (void)initServer {
    NSMutableDictionary *param = [NSMutableDictionary new];

    [IMOpenServerManager shareInstance].delegate = self;
    __weak typeof(self) weakSelf = self;
    [[IMOpenServerManager shareInstance] initializeServer:param completion:^(int code, NSString *message) {
        
    }];
}

#pragma mark - 收到消息
- (void)reciveMessage:(NSDictionary *)message {
    
}
#pragma mark - 发送消息
- (void)sendMessage {
    // 发送文本消息
    [[IMOpenServerManager shareInstance] sendMessageWithBody:@"测试" messageType:IMMessageBodyType_Text completion:^(int code, NSString *message) {
        
    }];
    
}
@end
