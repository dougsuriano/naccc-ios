//
//  DCBViewController.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import <UIKit/UIKit.h>

@interface DCBLoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

- (IBAction)login:(id)sender;


@end
