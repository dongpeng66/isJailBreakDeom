//
//  ViewController.m
//  isJailBreakDeom
//
//  Created by dp on 2021/5/19.
//

#import "ViewController.h"
#import "DPJailBreakCheck.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([DPJailBreakCheck isJailBreak]) {
        NSLog(@"越狱机型");
    }else{
        NSLog(@"非越狱机型");
    }
}


@end
