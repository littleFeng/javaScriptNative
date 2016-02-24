//
//  WKWebViewController.m
//  JavaScriptCoreDemo
//
//  Created by fenglishuai on 16/2/18.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "WKWebViewController.h"
#import "UIColor+Additions.h"
#import  <WebKit/WebKit.h>

#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height

@interface WKWebViewController ()
<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property(nonatomic,strong) WKWebView * wkwebView;

@property(nonatomic,strong) UIProgressView * progressView;

@end

@implementation WKWebViewController
{
    UILabel * label ;
    WKUserContentController * userContentController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    
    //注册供js调用的方法
    userContentController =[[WKUserContentController alloc]init];
    [userContentController addScriptMessageHandler:self  name:@"aaa"];
    [userContentController addScriptMessageHandler:self  name:@"closeWeb"];
    [userContentController addScriptMessageHandler:self  name:@"alert"];
    [userContentController addScriptMessageHandler:self  name:@"changeNav"];
    configuration.userContentController = userContentController;
    configuration.preferences.javaScriptEnabled = YES;
    _wkwebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0.0f, screen_width, screen_height) configuration:configuration];
    
    _wkwebView.backgroundColor = [UIColor clearColor];
    _wkwebView.UIDelegate = self;
    _wkwebView.navigationDelegate = self;
    _wkwebView.allowsBackForwardNavigationGestures =YES;//打开网页间的 滑动返回
    _wkwebView.allowsLinkPreview = YES;//允许预览链接

    [self.view addSubview:_wkwebView];

    label= [[UILabel alloc]init];
    label.textColor = [UIColor redColor];
    label.backgroundColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [_wkwebView.scrollView addSubview:label];
    
//    [self.view insertSubview:label belowSubview:_wkwebView];
    
    [self initProgressView];

    [_wkwebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];//注册observer 拿到加载进度
    
    //加载本地H5
//    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];
//    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"wkdemo"
//                                                          ofType:@"html"];
//    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
//                                                    encoding:NSUTF8StringEncoding
//                                                       error:nil];
//    [_wkwebView loadHTMLString:htmlCont baseURL:baseURL];
//
//    网络h5
    NSURL * url = [NSURL URLWithString:@"https://www.baidu.com"];
    [_wkwebView loadRequest:[NSURLRequest requestWithURL:url]];
    // Do any additional setup after loading the view.
    
}
-(void)initProgressView
{
    _progressView =[[UIProgressView alloc]initWithFrame:CGRectMake(0,64.0f, screen_width, 10.0f)];
    _progressView.tintColor = [UIColor blueColor];
    _progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:_progressView];
}
// observe get 进度条
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"])
    {
        _progressView.hidden = NO;
        CGFloat  progress = [ change[@"new"] floatValue];
        [_progressView setProgress:progress];
        if(progress==1.0)
        {
        _progressView.hidden =YES;
        }
    }

}

//MARK:view life cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [_wkwebView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"wkwebview dealloc");
}

//注册的方法要在view dealloc前 remove 否则 不走 dealloc 循环引用

-(void)viewDidDisappear:(BOOL)animated
{
    [userContentController removeScriptMessageHandlerForName:@"aaa"];
    [userContentController removeScriptMessageHandlerForName:@"closeWeb"];
    [userContentController removeScriptMessageHandlerForName:@"alert"];
    [userContentController removeScriptMessageHandlerForName:@"changeNav"];
    
    [super viewDidDisappear:animated];
}

//MARK:wkwebviewDelegate

//发送请求前 决定是否允许跳转
/*
 typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
 WKNavigationActionPolicyCancel,不允许
 WKNavigationActionPolicyAllow, 允许
 } NS_ENUM_AVAILABLE(10_10, 8_0);
 */

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"发送请求前 allow 跳转");
}

//接收到服务器响应 后决定是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
{
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"接收到响应后 allow 跳转");

}

//接收到服务器跳转响应后 调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"tiaozhuan");

}

//开始加载页面
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    NSLog(@"开始加载页面");
}

//加载页面数据完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载页面完成");
    NSLog(@"backlist ===%@",webView.backForwardList.backList);
    NSLog(@"forwordlst==%@",webView.backForwardList.forwardList);
    NSLog(@"url===%@",webView.backForwardList.currentItem.URL);
    
    //加载完成后 设置导航栏相关
    if(webView.backForwardList.backList.count !=0)
        [self setNavBarhaveCloseBtn:YES reloadBtn:YES];
    else
        [self setNavBarhaveCloseBtn:NO reloadBtn:NO];
    
//    _wkwebView.hidden = YES ;
    //扑捉到请求的https地址
    NSString * url = [webView.backForwardList.currentItem.URL absoluteString];
    NSRange range1=[url rangeOfString:@"://"];
    NSRange range2=[url rangeOfString:@".com"];
    NSString * text = [url substringWithRange:NSMakeRange(range1.location+range1.length, range2.location+range2.length -range1.location -range1.length )];
    label.text= text;
    [label sizeToFit];
    label.frame= CGRectMake((screen_width-CGRectGetWidth(label.frame))*0.5f, 70.0f, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));

}

//接收数据
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"接收数据中");
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
{
    NSLog(@"页面加载失败");
}

//关闭webView
-(void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"关闭了webview");
}
//实现注册的供js调用的oc方法

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if(message.name ==nil || [message.name isEqualToString:@""])
        return;
    //message body : js 传过来值
    NSLog(@"message.body ==%@",message.body);
    //message.name  js发送的方法名称
    if([message.name  isEqualToString:@"aaa"])
    {
        NSString * body = [message.body objectForKey:@"body"];
        [self logNumber:body];
        [self uilabel:body];
    }
    else if ([message.name isEqualToString:@"alert"])
    {
        NSString * body = [message.body objectForKey:@"body"];
        [self showAlert:body];
    }
    else if ([message.name isEqualToString:@"closeWeb"])
    {
        [self closeWeb];
    
    }
    else if ([message.name isEqualToString:@"changeNav"])
    {
        NSString * info =[message.body objectForKey:@"body"];
        
        NSArray * arr =[info componentsSeparatedByString:@"&"];
        [self changeNavBarColor:arr[0] title:arr[1]];
        
//        NSLog(@"js dic====%@",dic);
    }
    
}

//MARK:webview 导航栏操作相关

-(void)setNavBarhaveCloseBtn:(BOOL)have reloadBtn:(BOOL)reload
{
    UIBarButtonItem * item0 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(goback)];
    
    UIBarButtonItem * item =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(closeWeb)];

    UIBarButtonItem * item1 =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(relaodWeb)];
    
    NSMutableArray * items =[NSMutableArray array];
    if(have && reload)
    {
        [items addObject:item0];
        [items addObject:item];
        [items addObject:item1];
    }
    else if (have)
    {
        [items addObject:item0];
        [items addObject:item];
    }
    else if (reload)
        [items addObject:item1];

    self.navigationItem.leftBarButtonItems=items;
}

-(void)closeWeb
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)relaodWeb
{
    [_wkwebView reload];
}
-(void)goback
{
    [_wkwebView goBack];
}

//MARK:实现注册的供js调用的oc方法

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
    UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(200, 100, 100, 50)];
    lab.text= text;
    lab.textColor = [UIColor redColor];
    lab.backgroundColor = [UIColor blackColor];
    lab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lab];
    [lab sizeToFit];
}

-(void)changeNavBarColor:(NSString * )color title:(NSString * )title
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:color];
        self.title = title ;
    });
}

@end
