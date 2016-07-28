//
//  ViewController.m
//  超级猜图
//
//  Created by yangqinglong on 16/4/24.
//  Copyright © 2016年 杨清龙. All rights reserved.
//

#import "ViewController.h"
#import "YQLQuestion.h"
@interface ViewController ()<UIPreviewActionItem>
@property (nonatomic,strong) NSArray *questions;
@property (nonatomic,assign) int index;
@property (weak, nonatomic) IBOutlet UILabel *lblindex;
@property (weak, nonatomic) IBOutlet UIButton *btnScore;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (nonatomic,assign) CGRect iconFrame;
@property (nonatomic,weak) UIButton *cover;
@property (weak, nonatomic) IBOutlet UIView *answerView;
@property (weak, nonatomic) IBOutlet UIView *optionsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = -2;
    self.index++;
    [self nextQuestion];
}
-(NSArray *)questions{
    if (_questions == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"questions.plist" ofType:nil];
        NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *arrayModel = [NSMutableArray array];
        //遍历
        for (NSDictionary *dict  in arrayDict) {
            YQLQuestion *model = [YQLQuestion questionWithDict:dict];
            [arrayModel addObject:model];
        }
        _questions = arrayModel;
    }
    return  _questions;
}
- (IBAction)btnNextDidClicked {
    //1.索引next++
//    self.index++;
    
    [self nextQuestion];
}

- (IBAction)bigImage:(id)sender {
    //创建一个大小和self.view一样大的按钮，作为一个阴影
    self.iconFrame = self.btnIcon.frame;
    UIButton *btncover = [[UIButton alloc]init];
    btncover.frame = self.view.bounds;
    //把图片放到阴影上
    btncover.backgroundColor = [UIColor blackColor];
    btncover.alpha = 0;
    [self.view addSubview:btncover];
    [btncover addTarget:self action:@selector(smallImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:self.btnIcon];
    self.cover = btncover;
    //通过动画的方式吧图片放大
    
    CGFloat iconW = self.view.frame.size.width;
    CGFloat iconH = iconW;
    CGFloat iconX = 0;
    CGFloat iconY = (self.view.frame.size.height - iconH)/2;
    [UIView animateWithDuration:0.7 animations:^{
        btncover.alpha = 0.6;
        self.btnIcon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    }];
    
}
-(void)smallImage{
    [UIView animateWithDuration:0.6 animations:^{
        self.btnIcon.frame = self.iconFrame;
        self.cover.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.cover removeFromSuperview];
            self.cover = nil;
        }
    }];
}
- (IBAction)iconDidClicked:(id)sender {
    if (self.cover == nil) {
        [self bigImage:nil];
    }else{
        [self smallImage];
    }
}

-(void)nextQuestion{
    //1.索引next++
    self.index++;
    //判断索引越界，提示用户
    if (self.index == self.questions.count ) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"答题结束" message:@"重新开始" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"重新开始" style:UIPreviewActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            self.index = -1;
            [self nextQuestion];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

        //根据索引获取当前模型数据
    YQLQuestion *model = self.questions[self.index];
    //设置数据
    [self settingData:model];
    //创建答案按钮
    [self makeAnswerButtons:model];
    //创建待选按钮
    [self makeOptionsButton:model];
    
    
}
-(void)makeOptionsButton:(YQLQuestion *)model{
    //先让optionView 可以接受用户点击交互
    self.optionsView.userInteractionEnabled = YES;
    //先清除之前的待选按钮
    [self.optionsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //获取当前题目待选文字的按钮
    NSArray *words = model.options;
    //根据待选文字循环创建按钮
    CGFloat btnMargin = 10;
    CGFloat btnW = 35;
    CGFloat btnH = 35;
    int num = 7;
    CGFloat marginLeft = (self.optionsView.frame.size.width - num * btnW - (num - 1)*btnMargin)/2;
    for (int i= 0; i<words.count; i++) {
        //创建一个按钮
        UIButton *btnOpt = [[UIButton alloc]init];
        //给每个Btn加上一个tag值
        btnOpt.tag = i;
        //设置背景
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [btnOpt setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        [btnOpt setTitle:words[i] forState:UIControlStateNormal];
        [btnOpt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //设置frame
        int indexColum = i % num;
        int indexRow = i / num;
        CGFloat btnX = marginLeft + indexColum * (btnW + btnMargin);
        CGFloat btnY = btnMargin + indexRow * (btnH + btnMargin);
        
        btnOpt.frame = CGRectMake(btnX,btnY, btnW, btnH);
        //添加到optionView
        [self.optionsView addSubview:btnOpt];
    
        //注册单击事件
        [btnOpt addTarget:self action:@selector(optionButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)optionButtonDidClicked:(UIButton *)sender{
    
    //隐藏当前被点击的按钮
    sender.hidden = YES;
    //把当前被点击的文字显示到答案按钮上
//    NSString *text = [sender titleForState:UIControlStateNormal];
    NSString *text = sender.currentTitle;
    //吧文字显示到答案按钮上
    for (UIButton *answerBtn  in self.answerView.subviews) {
        //判断每个答案按钮上的答案文字
        if (answerBtn.currentTitle == nil) {
            //把当前点击的btn上的文字设置给对应的答案按钮
            [answerBtn setTitle:text forState:UIControlStateNormal];
            //把当前点击的按钮的tag值也设置给对应的答案按钮
            answerBtn.tag = sender.tag;
            break;
        }
    }
    BOOL isFull = YES;
    //拼接用户输入的字符串
    NSMutableString *userInput = [NSMutableString string];
    
    
    for (UIButton *btnAnswer in self.answerView.subviews) {
        if (btnAnswer.currentTitle == nil) {
            isFull = NO;
            break;
        }else{
            [userInput appendString:btnAnswer.currentTitle];
        }
    }
    //判断答案按钮是否已经满了
    if (isFull) {
        //禁止待选按钮被点击
        self.optionsView.userInteractionEnabled = NO;
        //获取正确答案
        YQLQuestion *model = self.questions[self.index];
        
        
        if ([model.answer isEqualToString:userInput]) {
            //判断答案是否正确，正确跳转下一题，
            //设置答案按钮的文字颜色为蓝色
            [self setAnswerButtonTitleColor:[UIColor blueColor]];
            //加分
            [self addScore:100];
            
            //延迟1秒后，跳转下一题
            [self performSelector:@selector(nextQuestion) withObject:nil afterDelay:0.5];
        }else{
            //        答案错误设置答案按钮的文字颜色为红色
            [self setAnswerButtonTitleColor:[UIColor redColor]];
            
        }
    }
    
}

//提取方法，设置答案按钮的字体颜色
-(void)setAnswerButtonTitleColor:(UIColor *)color{
    //遍历每一个答案按钮，设置文字颜色
    for (UIButton *btnAnswer in self.answerView.subviews) {
        [btnAnswer setTitleColor:color forState:UIControlStateNormal];
    }
}
//加分减分
-(void)addScore:(int)score{
    //获取当前分数，
    NSString *str = self.btnScore.currentTitle;
    //分数转成数字类型
    int currentScore = str.integerValue;
    //对分数操作
    currentScore = currentScore+score;
    //把新的分数设置给按钮
    [self.btnScore setTitle:[NSString stringWithFormat:@"%d",currentScore] forState:UIControlStateNormal];
    
}

//加载数据
-(void)settingData:(YQLQuestion *)model{
    //将模型数据设置在界面对应的空间上
    self.lblindex.text = [NSString stringWithFormat:@"%d / %d",(self.index+1),self.questions.count];
    self.lblTitle.text = model.title;
    [self.btnIcon setImage:[UIImage imageNamed:model.icon] forState:UIControlStateNormal];
    
    //设置到达最后一题禁用下一题按钮
    self.btnNext.enabled = (self.index!= self.questions.count-1);
    
}

//创建答案按钮
-(void)makeAnswerButtons:(YQLQuestion *)model{
    //动态创建答案按钮
    //创建前先清除之前的按钮
    //    while (self.answerView.subviews.firstObject) {
    //        [self.answerView.subviews.firstObject removeFromSuperview];
    //    }或者用下面的方法,让数组中的每一个对象分别调用这个方法，内部循环，无需我们自己来循环
    [self.answerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //获取当前答案的文字
    NSInteger len = model.answer.length;
    //循环创建答案按钮，有几个文字就创建几个按钮
    CGFloat margin = 10;
    CGFloat answerW = 35;
    CGFloat answerH = 35;
    CGFloat answerY = 0;
    CGFloat marginleft =(self.answerView.frame.size.width - ((35*len)+(len-1)*margin))/2;
    for (int i = 0; i<len; i++) {
        UIButton *btnAnswer = [[UIButton alloc]init];
        [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [btnAnswer setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        //frame设置
        CGFloat answerX = marginleft + i*(answerW + margin);
        btnAnswer.frame = CGRectMake(answerX, answerY, answerW, answerH);
        [btnAnswer setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //把按钮加到answerView中
        [self.answerView addSubview:btnAnswer];
        
        //为单机按钮添加点击事件
        [btnAnswer addTarget:self action:@selector(btnAnswerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)btnAnswerClick:(UIButton *)sender{
    //0,让option view 接收用户交互
    self.optionsView.userInteractionEnabled = YES;
    [self setAnswerButtonTitleColor:[UIColor blackColor]];
     
    //1,在待选按钮中找到与当前被点击的答案按钮文字相同待选按钮，设置该按钮显示出来
    for (UIButton *optBtn in self.optionsView.subviews) {
//        //比较判断待选按钮的文字是否与当前被点击的文字一致
//        if ([sender.currentTitle isEqualToString:optBtn.currentTitle]) {
//            optBtn.hidden = NO;
//            break;
//        }
        
        if (sender.tag == optBtn.tag) {
            optBtn.hidden = NO;
            break;
        }
    }
    
    //2，清空当前被点击的的答案按钮的文字
    [sender setTitle:nil forState:UIControlStateNormal];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (IBAction)btnTipClick:(id)sender {
    //分数减去1000
    [self addScore:-1000];
    //答案清空，调用答案按钮的单击事件
    for (UIButton *btnAnswer in self.answerView.subviews) {
        [self btnAnswerClick:btnAnswer];
    }
    //根据当前的索引，从数据数组中self。question中找到对应的数据模型
    //从数据模型中获取正确答案的第一个字符，把待选按钮和这个字符相等的按钮点击一下
    YQLQuestion *model = self.questions[self.index];
    //截取正确答案的第一个字符
    NSString *firstChar = [model.answer substringToIndex:1];
    //根据firstChar在option按钮中对应的option按钮，让这个按钮点击一下
    for (UIButton *btnOpt in self.optionsView.subviews) {
        if ([btnOpt.currentTitle isEqualToString:firstChar]) {
            [self optionButtonDidClicked:btnOpt];
            break;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end







