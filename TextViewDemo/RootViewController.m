//
//  RootViewController.m
//  TextViewDemo
//
//  Created by YiChe on 16/8/30.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickEdit:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    ViewController *aViewCtr = [story instantiateViewControllerWithIdentifier:@"ViewControllerStr"];
    [self.navigationController pushViewController:aViewCtr animated:YES];
}

- (IBAction)clickDisplay:(id)sender {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    ViewController *aViewCtr = [story instantiateViewControllerWithIdentifier:@"SecondViewController"];
    [self.navigationController pushViewController:aViewCtr animated:YES];
}
@end
