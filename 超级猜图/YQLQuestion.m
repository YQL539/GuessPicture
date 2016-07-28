//
//  YQLQuestion.m
//  超级猜图
//
//  Created by yangqinglong on 16/4/24.
//  Copyright © 2016年 杨清龙. All rights reserved.
//

#import "YQLQuestion.h"

@implementation YQLQuestion
-(instancetype)initWithDict:(NSDictionary *)Dict{
    if (self = [super init]) {
        self.answer = Dict[@"answer"];
        self.icon = Dict[@"icon"];
        self.title = Dict[@"title"];
        self.options = Dict[@"options"];
    }
    return self;
}

+(instancetype)questionWithDict:(NSDictionary *)Dict{
    return  [[self alloc]initWithDict:Dict];
}

@end
