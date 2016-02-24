//
//  ViewController.m
//  JavaScriptCoreDemo
//
//  Created by fenglishuai on 16/2/15.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "ViewController.h"

#import "JSProtocol.h"

#import <WebKit/WebKit.h>

#import "LSWebViewController.h"
#import "WKWebViewController.h"

@interface ViewController ()
<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) JSProtocol * jsprotocol;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.dataSource =self;
    _tableView.delegate   =self;
       // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}
-(UITableViewCell * ) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellid = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    if(indexPath.row == 0)
        cell.textLabel.text= @"基于JavaScriptCore的js oc 交互 iOS7";
    else if (indexPath.row == 1)
        cell.textLabel.text=@"WKWebview 的js oc 交互 iOS8";
    
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        LSWebViewController * vc= [[LSWebViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    
    }
    else if (indexPath.row == 1)
    {
        WKWebViewController * wbvc = [[WKWebViewController alloc]init];
        [self.navigationController pushViewController:wbvc animated:YES];
    
    }

}



@end
