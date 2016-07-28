//
//  YQLQuestion.h
//  超级猜图
//
//  Created by yangqinglong on 16/4/24.
//  Copyright © 2016年 杨清龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YQLQuestion : NSObject
@property (nonatomic,copy) NSString *answer;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,strong) NSArray *options;


-(instancetype)initWithDict:(NSDictionary *)Dict;
+(instancetype)questionWithDict:(NSDictionary *)Dict;

@end
