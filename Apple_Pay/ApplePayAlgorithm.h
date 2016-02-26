//
//  ApplePayAlgorithm.h
//  Apple_Pay
//
//  Created by 周双建 on 16/2/25.
//  Copyright © 2016年 周双建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplePayAlgorithm : NSObject
// All key order information dictionary value,all count 11
@property(nonatomic,strong) NSArray * OrderInfoAllKeysArray;
// The signature of the commodity order information, generate a signature dictionary
// orderinfodict 是订单数据信息字典
// signkey  有两种可能： 一种是商户号   一种是RSA秘钥
-(NSDictionary*)SignOrderInfoDict:(NSDictionary*)orderinfodict Signkey:(NSString*)signkey ;
// 将数据字典转化为字符串   （本脚本，主要用于，信息风险控制参数，以字符串的形式接入）
+(NSString*)GetString:(NSDictionary*)anyobjiect_dict;
// 将字符穿里面的特殊字符进行转化（转化成ASCII），避免发生错误。
+(NSString*)GetURLString:(NSString *)anyobject_string;
// 将特殊编码后的字符串进行解码
+(NSString*)GetURLDecodeString:(NSString*)anyobject_string;
// 进行字符串MD5加密
+(NSString*)GetMd5String:(NSString*)anyobject_string;
@end
