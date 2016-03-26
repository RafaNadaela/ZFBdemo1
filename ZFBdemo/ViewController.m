//
//  ViewController.m
//  ZFBdemo
//
//  Created by shangshan on 16/3/24.
//  Copyright © 2016年 shangshan. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ViewController ()

@end

@implementation ViewController
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}



- (IBAction)ZFBPay:(id)sender {
    
    //支付宝支付按钮方法
    
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    //商户ID:parnter.合作身份者ID,以 2088 开头由 16 位纯数字组成的字符串。如:2088501566833063
    NSString *partner = @"2088021795119191";//商户ID.
    //账户ID:seller.支付宝收款账号,手机号码或邮箱格式。如:chenglianshiye@yeah.net
    NSString *seller = @"3228823428@qq.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALpRFk7SDP7QuBrlLp1YD7AvHzwNk3G+dKBwav85XOWfzw93RVEtLf6bwvbLDE0yyPreVeTwAQrgj0pQQCaMzTbH5zjsCyfs7dvM0dL9hh8tyej5/Kyjim8M2yBDLFuT2M+nU+7Ns3DE8JIR5D3iggtJd/GC8E2b7/YpzC7+w7KtAgMBAAECgYEAktTUf8mJ9EcI0ClNUzLTKkX4l5sbV8iAoO/3YqwSSeRnigi02ASC+uRGAbiDOVOMkCgoCQQbzjaqtiYIaFkOX4UYbX+FoI8AvKCrT1yi3UqPdiWrkFoysJbWKT4B5TJnOySAio5oSQZVqH1VVZwVVZRzRAZp1KaQbQTo8+coyAECQQDkWPUjTii1TTpG3ovZ0eG7RZJgXlKGVugghX367fmAxJqCy/rAmYtDjsxK6NYYFKI7xijNFIPSBEDBuec9sD11AkEA0OEgdBprSdyHWGOniUi7KQQtGPnDFjUPSEvMsLbA+4rw4Z4+NSL62Hdtz+AHvnorn0GuurTz5fhM7xmcsMFhWQJAcgk++w+4YrqbpPLVEsWvHpAjBr90JSTXrg4cmSkpVjZZF4L4yiCkHOv+eFaJPONpFcLjc2+QWVzIXjcSFYujVQJAczebJS/lemqQparioRFjW66YCazLdZZzBZf6IofMT3RGhs041yqiX4ERK5cR7nmJUmFytj5WQsYB+emQytcAkQJAMUEj/lq1XQH4m39c3GEdwcRbNQ+4jcaw6a2ErgLVQ+quEkKOXZSr2q8Rm9t2r4s0yqJ7lr+iBn4oUCW1UvoYaQ==";
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        NSLog(@"缺少partner或者seller或者私钥。");
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）@"134123121231";
    order.productName = @"为啥额"; //商品标题
    order.productDescription = @"我的"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f", 0.19]; //商品价格
    //跟公司的后台服务器进行回调的.支付完成后,告诉公司的后台, 是支付成功,还是支付失败.
    order.notifyURL =  @"http://app.cheguchina.com/wash/unionpay/mobilenotify"; //回调URL
    //以下信息 是支付的基本配置信息
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"shangshan";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            //支付宝给我们的开发者的回调信息.
            //标示是成功还是失败.还是用户取消,网络中断等信息.
            NSLog(@"reslut = %@",resultDic);
        }];
        
    }
    

    
    
}









@end
