//
//  JSProtocol.h
//  JavaScriptCoreDemo
//
//  Created by fenglishuai on 16/2/16.
//  Copyright © 2016年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
//定义一个JSExport protocol

@protocol JSExportDelegate <JSExport>

//协议 方法 和 属性
//用宏将oc方法名 转成 js方法名 方便js调用

JSExportAs(add, -(NSInteger)addA:(NSInteger)a andB:(NSInteger)b);

@property(nonatomic,strong) NSString * name;

@end

//实现协议方法

@interface JSProtocol : NSObject<JSExportDelegate>

@end
