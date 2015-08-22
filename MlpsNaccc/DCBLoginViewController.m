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
    [[DCBAPIManager sharedManager] obtainOAuthTokenWithUsername:self.usernameField.text password:self.passwordField.text success:^(NSString *token) {
        [self enableUserInput];
        [self.usernameField setText:@""];
        [self.passwordField setText:@""];
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
    [self.usernameField setEnabled:YES];
    [self.passwordField setEnabled:YES];
    [self.loginButton setEnabled:YES];
}

- (void)disableUserInput
{
    [self.usernameField setEnabled:NO];
    [self.passwordField setEnabled:NO];
    [self.loginButton setEnabled:NO];
    [self.view endEditing:YES];
}

- (void)checkLogin
{
    [[DCBAPIManager sharedManager] authorizedPing:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self userLoggedIn];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.usernameField becomeFirstResponder];
    }];
}

- (void)userLoggedIn
{
    DCBAvailableCheckpointsViewController *vc = [[DCBAvailableCheckpointsViewController alloc] initWithNibName:@"DCBAvailableCheckpointsViewController" bundle:nil];
    UINavigationController *nav = [[DCBNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];

}

@end
