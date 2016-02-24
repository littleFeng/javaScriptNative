//
//  JSProtocol.m
//  JavaScriptCoreDemo
//
//  Created by fenglishuai on 16/2/16.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "JSProtocol.h"

@implementation JSProtocol
@synthesize name=_name;

-(NSInteger)addA:(NSInteger)a andB:(NSInteger)b
{
    NSInteger sum = a + b;    
    return sum;
}

-(void)setName:(NSString *)name
{
    _name = name;
}

@end
