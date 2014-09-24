//
//  DCBViewController.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import "DCBAvailableCheckpointsViewController.h"
#import "DCBLoginViewController.h"
#import "DCBAPIManager.h"
#import "DCBNavigationController.h"
#import <TWMessageBarManager/TWMessageBarManager.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DCBLoginViewController ()

- (void)enableUserInput;
- (void)disableUserInput;
- (void)checkLogin;
- (void)userLoggedIn;

@end

@implementation DCBLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self checkLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    [self disableUserInput];
    [[DCBAPIManager sharedManager] obtainOAuthTokenWithUsername:_usernameField.text password:_passwordField.text success:^(NSString *token) {
        [self enableUserInput];
        [_usernameField setText:@""];
        [_passwordField setText:@""];
        [self userLoggedIn];
            } failure:^(NSError *error) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Error Logging In"
                                                       description:@"An error occured while logging in. Please check your username/password and try again"
                                                              type:TWMessageBarMessageTypeError];
        [self enableUserInput];
    }];
}

- (void)enableUserInput
{
    [_usernameField setEnabled:YES];
    [_passwordField setEnabled:YES];
    [_loginButton setEnabled:YES];
}

- (void)disableUserInput
{
    [_usernameField setEnabled:NO];
    [_passwordField setEnabled:NO];
    [_loginButton setEnabled:NO];
    [self.view endEditing:YES];
}

- (void)checkLogin
{
    [[DCBAPIManager sharedManager] authorizedPing:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self userLoggedIn];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_usernameField becomeFirstResponder];
    }];
}

- (void)userLoggedIn
{
    DCBAvailableCheckpointsViewController *vc = [[DCBAvailableCheckpointsViewController alloc] initWithNibName:@"DCBAvailableCheckpointsViewController" bundle:nil];
    UINavigationController *nav = [[DCBNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];

}

@end
