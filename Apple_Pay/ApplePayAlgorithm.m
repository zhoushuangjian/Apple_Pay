//
//  ApplePayAlgorithm.m
//  Apple_Pay
//  本脚本，主要是进行  MD5的加密或者散列式加密和支付订单数据的处理过程
//  Created by 周双建 on 16/2/25.
//  Copyright © 2016年 周双建. All rights reserved.
//

#import "ApplePayAlgorithm.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
@interface ApplePayAlgorithm(){
    // 用于存放错误日志
    NSMutableDictionary * ErrorMessageDictInfo;
}
// 用于接收签名字符串
@property(strong,nonatomic) NSString * SingKey;
// 用于接收秘钥字符串
@property(strong,nonatomic) NSString * RsaKey;
@end
@implementation ApplePayAlgorithm
-(NSDictionary*)SignOrderInfoDict:(NSDictionary*)orderinfodict Signkey:(NSString*)signkey {
    if(signkey.length==0){
        if (ErrorMessageDictInfo) {
            [ErrorMessageDictInfo setObject:@"第20行，传入的singkey是空值" forKey:@"signkey_20"];
        }
    }
    // 转化成可变的字符串，因为要进行数据的签名更改
    NSMutableDictionary * TempMutableDict = [NSMutableDictionary dictionaryWithDictionary:orderinfodict];
    // 创建一个签名后返回的一个字符串
    NSString * SignOverString = [self GetString:orderinfodict];
    // 将签名后的字符串，添加到ORDER INFO 里面
    [TempMutableDict setObject:SignOverString forKey:@"sign"];
    // 输出字典
    NSLog(@"wo de :%@",TempMutableDict);
    return TempMutableDict;
}
-(NSString*)GetString:(NSDictionary*)anyobjiect_dict{
    // 创建一个局部数组，防止OrderInfoAllKeysArray 为空
    NSArray * AllKeys = @[@"busi_partner",@"dt_order",@"info_order",
                          @"money_order",@"name_goods",@"no_order",
                          @"notify_url",@"oid_partner",@"risk_item", @"sign_type",
                          @"valid_order"];
    if (self.OrderInfoAllKeysArray != nil) {
        // 如果OrderInfoAllKeysArray 存在将 Allkeys 替代
        AllKeys = self.OrderInfoAllKeysArray;
    }
    if (ErrorMessageDictInfo) {
        [ErrorMessageDictInfo setObject:@"OrderInfoAllKeysArray 没有传入" forKey:@"AllKeys"];
    }
    // 将一个不可变的数组，可变化。进行数组对象字母排序
    NSMutableArray * LetterKeysArray = [NSMutableArray arrayWithArray:AllKeys];
    [LetterKeysArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    // 声明一个可变的字符串，将字典转化为字符串
    NSMutableString * PiecedMutableString = [[NSMutableString alloc]initWithCapacity:0];
    for (NSString * tempstr in LetterKeysArray) {
        if ([anyobjiect_dict[tempstr] length] != 0) {
            [PiecedMutableString appendFormat:@"&%@=%@",tempstr,anyobjiect_dict[tempstr]];
        }
    }
    // 进行可变的字符串进行处理
    if (PiecedMutableString.length != 0) {
        // 删除字符串的第一个字符：@“&”
         [PiecedMutableString deleteCharactersInRange:NSMakeRange(0, 1)];
    }else{
        if(ErrorMessageDictInfo){
            [ErrorMessageDictInfo setObject:@"65行 可变字符串不存在" forKey:@"PiecedMutableString"];
        }
    }
    if ([anyobjiect_dict[@"sign_type"] isEqualToString:@"MD5"]) {
        // 拼接上签名的Key-Value
        [PiecedMutableString appendFormat:@"&key=%@",self.SingKey];
    }
    // 声明要输出的字符串对象
    NSString * Return_SignString = nil;
    if([anyobjiect_dict[@"sign_type"] isEqualToString:@"MD5"]){
      Return_SignString = [ApplePayAlgorithm GetMd5String:PiecedMutableString];
    }else{
      // 哈希加密
      Return_SignString = [ApplePayAlgorithm signHmacString:PiecedMutableString withKey:self.SingKey];
    }
#ifdef kLLPayUtilNeedRSASign
    id<LLPDataSigner> signer = LLPCreateRSADataSigner(self.signKey);
    signString = [signer signString:paramString];
#endif
    // 输出加密后的字符串
    NSLog(@"签名字符串：%@",Return_SignString);
    return Return_SignString;
}
+(NSString*)GetMd5String:(NSString*)anyobject_string{
    // 进行编码转换成字符
    const char *original_str = [anyobject_string UTF8String];
    unsigned char result[32];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);//调用md5
    NSMutableString * MD5_String = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [ MD5_String appendFormat:@"%02x", result[i]];
    }
    return MD5_String;
}
+ (NSString *)signHmacString:(NSString*)text withKey:(NSString*)key{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSString *hash= nil;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", cHMAC[i]];
    }
    hash = output;
    return hash;
}
+(NSString*)GetString:(NSDictionary *)anyobjiect_dict{
    NSString * String = nil;
    NSData * Data = [NSJSONSerialization dataWithJSONObject:anyobjiect_dict options:NSJSONWritingPrettyPrinted error:nil];
    if (Data) {
        String = [[NSString alloc] initWithData:Data encoding:NSUTF8StringEncoding];
    }
    return String;
}
+(NSString*)GetURLString:(NSString *)anyobject_string{
    // ARC
    #if __has_feature(objc_arc)
    NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                    (__bridge CFStringRef)anyobject_string,
                                                                                    NULL,
                                                                                    CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                    kCFStringEncodingUTF8);
    #else
    // 非ARC
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
   #endif
    return result;
}
+(NSString*)GetURLDecodeString:(NSString*)anyobject_string{
    NSString *result = [anyobject_string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

@end
