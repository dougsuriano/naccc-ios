//
//  DCBNavigationController.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/18/14.
//
//

#import "DCBNavigationController.h"

@interface DCBNavigationController ()

@end

@implementation DCBNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:44.0f/255.0f green:62.0f/255.0f blue:80.0f/255.0f alpha:1.0f]];
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:24.0f],
                                                 NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
