//
//  LSWebViewController.m
//  JavaScriptCoreDemo
//
//  Created by fenglishuai on 16/2/16.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "LSWebViewController.h"
#import "UIColor+Additions.h"

#import <JavaScriptCore/JavaScriptCore.h>

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface LSWebViewController ()
<UIWebViewDelegate>
@property(nonatomic,strong) UIWebView * webView;

@property(nonatomic,strong) NSString     * url;

@property(nonatomic,strong) UINavigationBar * bar ;

@property(nonatomic,strong) UIScreenEdgePanGestureRecognizer * panRecognizer;

@end

@implementation LSWebViewController

-(instancetype)initWithUrl:(NSString *)urlString
{
    self = [super init];
    if(self)
    {
        _url= urlString;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0.0f, screen_width, screen_height)];
    _webView.delegate =self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.userInteractionEnabled = YES;
    _webView.scalesPageToFit =YES;
    _webView.multipleTouchEnabled = YES;
    _webView.contentMode = UIViewContentModeScaleAspectFit;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.allowsInlineMediaPlayback = YES;
    [self.view addSubview:_webView];
    
    _panRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(panBack:)];
    _panRecognizer.edges = 50.0f;
    [_webView addGestureRecognizer:_panRecognizer];
    
//    //加载本地H5
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"demo"
//                                                          ofType:@"html"];
//    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
//                                                    encoding:NSUTF8StringEncoding
//                                                       error:nil];
//    [self.webView loadHTMLString:htmlCont baseURL:baseURL];
    
//加载url
    _url = @"https://www.baidu.com";
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panRecognizer)
    {
        return YES;
    }
    return NO;
}

-(void)panBack:(UIScreenEdgePanGestureRecognizer * )rec
{
    
    NSLog(@"111");

}
//MARK:webView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"request===%@",request);
    NSRange range1=[_url rangeOfString:@"://"];
    NSRange range2=[_url rangeOfString:@".com"];
    NSString * text = [_url substringWithRange:NSMakeRange(range1.location+range1.length, range2.location+range2.length -range1.location -range1.length )];
    UILabel * label = [[UILabel alloc]init];
    label.text= text;
    label.textColor = [UIColor redColor];
    label.backgroundColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [self.view insertSubview:label belowSubview:_webView];
    [label sizeToFit];
    label.frame= CGRectMake((screen_width-CGRectGetWidth(label.frame))*0.5f, 70.0f, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //js 调oc 方法
    //创建js环境 可能是私有方法
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
//    JSContext * context = [[JSContext alloc]init];
    
    // 打印异常
    context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息====%@",exceptionValue);
    };
    
    //定义协议方法 注册供js调用的oc方法
    __weak typeof (self) weakSelf = self;
    
    context[@"aaa"] =^(NSString * number)
    {
        [weakSelf logNumber:number];
        [weakSelf uilabel:number];
    };
    context[@"alert"]=^(NSString * info)
    {
        [weakSelf showAlert:info];
    };
    context[@"log"]=^(id info)
    {
        NSLog(@"msg====%@",info);
    };
    context[@"closeWeb"]=^(void){
        [weakSelf closeWeb];
    };
    
    context[@"changeNavBar"]=^(NSString * color,NSString * title){
        NSLog(@"color===%@",color);
        NSLog(@"title==%@",title);
        [weakSelf changeNavBarColor:color title:title];
    };
    
    context[@"dictionary"]=^(NSDictionary * dic){
    
        NSLog(@"dictionary_key1===%@",dic[@"a"]);
        NSLog(@"dictionary_key2===%@",dic[@"b"]);
    };

    // oc  调 js 传参
    [self evaluateJSMethod:@"alertClick(1232132132)"];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{

}

-(void)showAlert:(NSString * )msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

-(void)logNumber:(NSString *)number
{
    NSLog(@"jsValue=======%@",number);
    
}
-(void)uilabel:(NSString * )text
{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(200, 100, 100, 50)];
    label.text= text;
    label.textColor = [UIColor redColor];
    label.backgroundColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label sizeToFit];
}

-(void)changeNavBarColor:(NSString * )color title:(NSString * )title
{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:color];
        self.title = title ;
    });
}

-(void)closeWeb
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

//oc 调 js
-(void)evaluateJSMethod:(NSString * )method
{
    //创建js环境
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [context evaluateScript:method];
    
}

//MARK:view cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"uiwebview dealloc");
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];

}

@end
