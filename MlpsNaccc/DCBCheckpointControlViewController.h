//
//  DCBVCheckpointControliewController.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import <UIKit/UIKit.h>

@class DCBCheckpoint;

@interface DCBCheckpointControlViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *currentStateView;
@property (nonatomic, strong) IBOutlet UIView *racerNumberView;
@property (nonatomic, strong) IBOutlet UIView *pickOrDropView;
@property (nonatomic, strong) IBOutlet UIView *pickJobNumberView;
@property (nonatomic, strong) IBOutlet UIView *pickConfirmView;
@property (nonatomic, strong) IBOutlet UIView *dropConfirmCodeView;
@property (nonatomic, weak) IBOutlet UITextField *racerNumberField;
@property (nonatomic, weak) IBOutlet UILabel *racerNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *jobNumberField;
@property (nonatomic, weak) IBOutlet UILabel *confirmCodeLabel;
@property (nonatomic, weak) IBOutlet UITextField *confirmCodeField;

- (instancetype)initWithCheckpoint:(DCBCheckpoint *)checkpoint;
- (IBAction)lookupRacer:(id)sender;
- (IBAction)wrongRacer:(id)sender;
- (IBAction)pick:(id)sender;
- (IBAction)drop:(id)sender;
- (IBAction)jobNumberEnter:(id)sender;
- (IBAction)cancelJobNumberEntry:(id)sender;
- (IBAction)nextRacer:(id)sender;
- (IBAction)confirmCodeEnter:(id)sender;
- (IBAction)cancelConfirmCode:(id)sender;

@end
