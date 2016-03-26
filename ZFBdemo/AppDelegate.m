//
//  AppDelegate.m
//  ZFBdemo
//
//  Created by shangshan on 16/3/24.
//  Copyright © 2016年 shangshan. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

#pragma mark--这个方法是处理从其他应用跳转回来的方法，具体从哪个应用跳转回来的是"sourceApplication"

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    //跳转到支付宝钱包进行支付, 并且要处理支付 结果
    
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        
       //跳转的时候要发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZFBreturn" object:nil];
        
//        if ([resultDic[@"resultStatus"] isEqual:@"9000"] ) {
//            
//            UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"成功" message:@"确定" preferredStyle:0] ;
//            
//        
//                                     
//                                     
//            
//        }
        
        if ( [resultDic[@"resultStatus"] isEqual:@"9000"]) {
            UIAlertView *alter =  [[UIAlertView alloc]initWithTitle:@"支付成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        }else if( [resultDic[@"resultStatus"] isEqual:@"6001"]){
            UIAlertView *alter =  [[UIAlertView alloc]initWithTitle:@"您已取消支付" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        }else if([resultDic[@"resultStatus"] isEqual:@"6002"]){
            UIAlertView *alter =  [[UIAlertView alloc]initWithTitle:@"网络连接错误" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        }else if ([resultDic[@"resultStatus"] isEqual:@"4000"]){
            UIAlertView *alter =  [[UIAlertView alloc]initWithTitle:@"订单支付失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
            
        }else if([resultDic[@"resultStatus"] isEqual:@"8000"]){
            UIAlertView *alter =  [[UIAlertView alloc]initWithTitle:@"订单正在处理中" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alter show];
        }
  
        
        
    }];

    return YES;
}







- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
