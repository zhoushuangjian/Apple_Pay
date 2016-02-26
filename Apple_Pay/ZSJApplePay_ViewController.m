//
//  ZSJApplePay_ViewController.m
//  Apple_Pay
//
//  Created by 周双建 on 16/2/24.
//  Copyright © 2016年 周双建. All rights reserved.
//

#import "ZSJApplePay_ViewController.h"
#import "LLPaySdk.h"
#import "ApplePayCommont.h"
#import "ApplePayAlgorithm.h"
#define ImageCount 33
@interface ZSJApplePay_ViewController ()<UITableViewDataSource,UITableViewDelegate,LLPaySdkDelegate>
@property(strong,nonatomic) NSMutableArray * ImageViewArray;
@property(strong) NSMutableArray * SourceArray;
// 声明一个支付对象
@property(nonatomic,strong) LLAPPaySDK * ApplePaySdk;
// 订单信息
@property(nonatomic,strong) NSMutableDictionary * OrderInfoMutableDict;
@end

@implementation ZSJApplePay_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"成功QQ吧~~ApplePay";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    self.ImageViewArray = [NSMutableArray arrayWithCapacity:0];
    self.SourceArray = [NSMutableArray arrayWithObjects:@"Pay 支付",@"Auth 预授权", nil];
    UIImageView * ApplePayBackImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
    ApplePayBackImage.userInteractionEnabled = YES;
   // ApplePayBackImage.contentMode = UIViewContentModeScaleAspectFit;
    for (int i =1; i<=ImageCount; i++) {
        [self.ImageViewArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]]];
    }
    if (_ImageViewArray.count==0) {
        return;
    }
    ApplePayBackImage.animationImages = self.ImageViewArray;
    ApplePayBackImage.animationDuration = 10.0f;
    ApplePayBackImage.animationRepeatCount = 0;
    [self.view addSubview:ApplePayBackImage];
    [ApplePayBackImage startAnimating];
    UITableView * ApplePayTableView = [[UITableView alloc]initWithFrame:CGRectMake(71, 100, 240, 503) style:UITableViewStyleGrouped];
    ApplePayTableView.delegate = self;
    ApplePayTableView.dataSource = self;
    ApplePayTableView.showsVerticalScrollIndicator = NO;
    ApplePayTableView.backgroundColor = [UIColor clearColor];
    [ApplePayBackImage addSubview:ApplePayTableView];
    // 创建订单信息
    [self CreateOrderInfo];
    // Do any additional setup after loading the view.
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 210.f;
    }
    return 40.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    return self.SourceArray.count ;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30.f;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * ApplePayCell = nil;
    if (indexPath.section==0) {
      ApplePayCell   = [tableView dequeueReusableCellWithIdentifier:@"Pay_ID"];
        if (!ApplePayCell) {
            ApplePayCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Pay_ID"];
            // 展示图片
            UIImageView * ImageView = [[UIImageView alloc]init];
            ImageView.tag = 100 ;
            [ApplePayCell.contentView addSubview:ImageView];
            // 产品介绍
            UILabel * DescribeLabel = [[UILabel alloc]init];
            DescribeLabel.tag = 200;
            [ApplePayCell.contentView addSubview:DescribeLabel];
            // 商品的价格
            UILabel * PriceLabel = [[UILabel alloc]init];
            PriceLabel.tag = 300;
            [ApplePayCell.contentView addSubview:PriceLabel];
        }
        UIImageView * ApplePay_ImageView = (UIImageView*)[ApplePayCell viewWithTag:100];
        ApplePay_ImageView.frame = CGRectMake(0, 5, CGRectGetWidth(ApplePayCell.frame), 120);
        ApplePay_ImageView.image = [UIImage imageNamed:@"pifu.jpg"];
        UILabel * ApplePayDescribeLabel = (UILabel*)[ApplePayCell viewWithTag:200];
        ApplePayDescribeLabel.frame = CGRectMake(0, CGRectGetMaxY(ApplePay_ImageView.frame)+5, CGRectGetWidth(ApplePayCell.frame), 60);
        NSMutableAttributedString * StrLabel = [[NSMutableAttributedString alloc]initWithString:@"   琴女:\n  \t 琴瑟仙女,别名娑娜,琴女。"];
        [StrLabel  setAttributes:@{NSForegroundColorAttributeName:[UIColor magentaColor],NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(10, 14)];
        ApplePayDescribeLabel.attributedText = StrLabel ;
        ApplePayDescribeLabel.numberOfLines = 2;
       [ApplePayDescribeLabel sizeToFit];
       UILabel * ApplePayPriceLabel = (UILabel*)[ApplePayCell viewWithTag:300];
        ApplePayPriceLabel.frame = CGRectMake(0, CGRectGetMaxY(ApplePayDescribeLabel.frame)+5, CGRectGetWidth(ApplePayCell.frame), 30);
        ApplePayPriceLabel.text = @"   价格:￥ 250";
        ApplePayPriceLabel.font = [UIFont systemFontOfSize:15];
        
    }else{
        ApplePayCell   = [tableView dequeueReusableCellWithIdentifier:@"Pay_ID_ONE"];
        if (!ApplePayCell) {
            ApplePayCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Pay_ID_ONE"];
        }
        ApplePayCell.textLabel.text = self.SourceArray[indexPath.row];
    }
    return ApplePayCell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0){
       return @"ORDER INFO";
    }
    return @"Payment Method";

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        //进行订单签名
        [self fillOrderMethodAndUserinfo];
        NSDictionary * SignTempDict = [self SignGoON];
        switch (indexPath.row) {
            case 0:{
                [self payWithSignedOrder:SignTempDict];
            }
                break;
            case 1:{
                [self authWithSignedOrder:SignTempDict];
            }
                break;
            default:
                break;
        }
    }
}
- (NSString*)fillOrderMethodAndUserinfo{
    [self.OrderInfoMutableDict removeObjectForKey:@"acct_name"];
    [self.OrderInfoMutableDict removeObjectForKey:@"id_no"];
    [self.OrderInfoMutableDict removeObjectForKey:@"no_agree"];
    [self.OrderInfoMutableDict removeObjectForKey:@"card_no"];
    return nil;
}

-(NSDictionary*)SignGoON{
    ApplePayAlgorithm * ApplePayA = [[ApplePayAlgorithm alloc]init];
    NSDictionary *signedOrder = [ApplePayA SignOrderInfoDict:self.OrderInfoMutableDict Signkey:self.OrderInfoMutableDict[@"oid_partner"]];
    return signedOrder;
}
// 进行支付
- (void)payWithSignedOrder:(NSDictionary*)signedOrder
{
    [LLAPPaySDK sharedSdk].sdkDelegate = self;
    [[LLAPPaySDK sharedSdk] payWithTraderInfo:signedOrder
                             inViewController:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark 创建订单
-(void)CreateOrderInfo{
    // 获取当前时间
    NSDateFormatter * DateFormatter = [[NSDateFormatter alloc]init];
    [DateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    // 将时间转化成字符串
    NSString * PresentTimeString = [DateFormatter stringFromDate:[NSDate date]];
    // 订单前的标志
    NSString * OrderPresentSign = @"LL";
    // 加密的形式 MD5   RSA   哈希
    NSString * SignType = @"MD5";
    // 声明一个可变的参数字典
    self.OrderInfoMutableDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * PrameMutableDict  = [NSMutableDictionary dictionary];
    [PrameMutableDict setDictionary:@{
                          //签名方式	String	RSA  或者 MD5
                           @"sign_type":SignType,
                           //商户业务类型是String(6)虚拟商品销售：101001
                           @"busi_partner":@"101001",
                           //商户订单时间	dt_order是String(14)	格式：YYYYMMDDH24MISS  14位数字，精确到秒
                           @"dt_order":PresentTimeString,
                           //交易金额	money_order	是	Number(8,2)	该笔订单的资金总额，单位为RMB-元。大于0的数字，精确到小数点后两位。 如：49.65
                           @"money_order":@"0.10",
                           //服务器异步通知地址	notify_url	是	String(64)	连连钱包支付平台在用户支付成功后通知商户服务端的地址。
                           @"notify_url":@"http://test.yintong.com.cn:80/apidemo/API_DEMO/notifyUrl.htm",
                           //商户唯一订单号	no_order	是	String(32)	商户系统唯一订单号
                           @"no_order":[NSString stringWithFormat:@"%@%@",OrderPresentSign,PresentTimeString],
                           //商品名称	name_goods	否	String(40)
                           @"name_goods":@"琴女的皮肤",
                           //订单附加信息	info_order	否	String(255)	商户订单的备注信息，还可以详细描述。
                           @"info_order":PresentTimeString,
                           //分钟为单位，默认为10080分钟（7天），从创建时间开始，过了此订单有效时间此笔订单就会被设置为失败状态不能再重新进行支付。
                           @"valid_order":@"10080",
                           //@"shareing_data":@"201412030000035903^101001^10^分账说明1|201310102000003524^101001^11^分账说明2|201307232000003510^109001^12^分账说明3"
                           // 分账信息数据 shareing_data  否 变(1024)
                           //@"risk_item":@"{\"user_info_bind_phone\":\"13958069593\",\"user_info_dt_register\":\"20131030122130\"}",
                           //风险控制参数 否 此字段填写风控参数，采用json串的模式传入，字段名和字段内容彼此对应好
                           //商户用户唯一编号 否 该用户在商户系统中的唯一编号，要求是该编号在商户系统中唯一标识该用户
                           // user_id，一个user_id标示一个用户
                           // user_id为必传项，需要关联商户里的用户编号，一个user_id下的所有支付银行卡，身份证必须相同
                           // demo中需要开发测试自己填入user_id, 可以先用自己的手机号作为标示，正式上线请使用商户内的用户编号
                           @"risk_item" : [ApplePayAlgorithm GetString:@{@"user_info_dt_register":@"20131030122130",@"cinema_name":@"大电影院",@"book_phone":@"18811520397"}],@"user_id":@"xu20160215",
                           @"oid_partner":kLLOidPartner
                            }];
    self.OrderInfoMutableDict = PrameMutableDict;
    // matech ID   预支付AP ID
    self.OrderInfoMutableDict[@"ap_merchant_id"] = kAPMerchantID;
    if (kLLOidPartner.length > 0) {
        // 商户秘钥
        self.OrderInfoMutableDict[@"oid_partner"] = kLLOidPartner;
        return;
    }
}
#pragma mark  支付结果的返回
/* kLLPayResultSuccess = 0,    // 支付成功
kLLPayResultFail = 1,       // 支付失败
kLLPayResultCancel = 2,     // 支付取消，用户行为
kLLPayResultInitError,      // 支付初始化错误，订单信息有误，签名失败等
kLLPayResultInitParamError, // 支付订单参数有误，无法进行初始化，未传必要信息等
kLLPayResultUnknow,         // 其他
*/
- (void)paymentEnd:(LLPayResult)resultCode withResultDic:(NSDictionary*)dic{
    [self alertView:[ApplePayAlgorithm GetString:dic]];
    switch (resultCode) {
        case kLLPayResultSuccess:{
          // 支付成功
            NSString* result_pay = dic[@"result_pay"];
            if ([result_pay isEqualToString:@"SUCCESS"])
            {
                [self alertView:@"SUCCESS"];

            }
            else if ([result_pay isEqualToString:@"PROCESSING"])
            {
                //@"支付单处理中";
                [self alertView:@"支付单处理中"];

            }
            else if ([result_pay isEqualToString:@"FAILURE"])
            {
                // @"支付单失败";
                [self alertView:@"支付单失败"];

            }
            else if ([result_pay isEqualToString:@"REFUND"])
            {
                // @"支付单已退款";
                [self alertView:@"支付单已退款"];

            }

        }
            break;
        case kLLPayResultFail:{
          // 支付失败
           [self alertView:@"支付失败"];
            

        }
            break;
        case kLLPayResultCancel:{
           // 用户取消支付
            [self alertView:@"用户取消支付"];

        }
            break;
        case kLLPayResultInitError:{
            [self alertView:@"支付初始化错误，订单信息有误，签名失败等"];

           //支付初始化错误，订单信息有误，签名失败等
        }
            break;
        case kLLPayResultInitParamError:{
            [self alertView:@"支付订单参数有误，无法进行初始化，未传必要信息等"];
        }
            
            break;
        case kLLPayResultUnknow:{
            //其他
            [self alertView:@"其他"];
        }
            
            break;
        default:
            break;
    }
    
}
#pragma mark  预授权
- (void)authWithSignedOrder:(NSDictionary*)signedOrder{
    [LLAPPaySDK sharedSdk].sdkDelegate = self;
    [[LLAPPaySDK sharedSdk] preauthWithTraderInfo:signedOrder
                                 inViewController:self];
}
-(void)alertView:(NSString*)str{
    [[[UIAlertView alloc] initWithTitle:@"结果"
                                message:str
                               delegate:nil
                      cancelButtonTitle:@"确认"
                      otherButtonTitles:nil] show];

}
@end
