//
//  DCBVCheckpointControliewController.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import "DCBCheckpointControlViewController.h"
#import "DCBCheckpoint.h"
#import "DCBRacer.h"
#import "DCBAPIManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <TWMessageBarManager/TWMessageBarManager.h>

typedef NS_ENUM(NSUInteger, DCBCheckpointControlState) {
    DCBCheckpointControlStateRacerNumber,
    DCBCheckpointControlStatePickOrDrop,
    DCBCheckpointControlStatePickJobNumber,
    DCBCheckpointControlStatePickConfirm,
    DCBCheckpointControlStateDropNumber
};

typedef NS_ENUM(NSUInteger, DCBTransactionType) {
    DCBTransactionTypePick,
    DCBTransactionTypeDrop
};

@interface DCBCheckpointControlViewController ()

@property (nonatomic, strong) DCBCheckpoint *currentCheckpoint;
@property (nonatomic, strong) DCBRacer *currentRacer;
@property (nonatomic, assign) DCBTransactionType transactionType;
@property (nonatomic, strong) NSNumber *currentState;
@property (nonatomic, strong) DCBRacer *lastRacer;
@property (nonatomic, strong) NSString *lastConfirmCode;

- (void)changeToControlState:(DCBCheckpointControlState)state hideMessageBar:(BOOL)hide;
- (void)showLoadingHUD;
- (void)hideLoadingHUD;
- (void)flashColor:(UIColor *)color;
- (void)updateLastConfirmCode:(NSString *)code racer:(DCBRacer *)racer;
- (IBAction)showLastConfirmCode:(id)sender;

@end

@implementation DCBCheckpointControlViewController

- (instancetype)initWithCheckpoint:(DCBCheckpoint *)checkpoint
{
    self = [super initWithNibName:@"DCBCheckpointControlViewController" bundle:nil];
    if (self) {
        self.title = [checkpoint checkpointName];
        _currentCheckpoint = checkpoint;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"currentState" options:NSKeyValueObservingOptionOld context:nil];
    [self changeToControlState:DCBCheckpointControlStateRacerNumber hideMessageBar:YES];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentState"];
}

#pragma mark Control State

- (void)changeToControlState:(DCBCheckpointControlState)state hideMessageBar:(BOOL)hide
{
    if (hide) {
        [[TWMessageBarManager sharedInstance] hideAll];
    }
    
    [[self.currentStateView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *view;
    switch (state) {
        case DCBCheckpointControlStateRacerNumber:
            view = self.racerNumberView;
            break;
        case DCBCheckpointControlStatePickOrDrop:
            view = self.pickOrDropView;
            break;
        case DCBCheckpointControlStatePickJobNumber:
            view = self.pickJobNumberView;
            break;
        case DCBCheckpointControlStatePickConfirm:
            view = self.pickConfirmView;
            break;
        case DCBCheckpointControlStateDropNumber:
            view = self.dropConfirmCodeView;
            break;
    }
    [self.currentStateView addSubview:view];
    [self setCurrentState:@(state)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self.currentState integerValue] == DCBCheckpointControlStateRacerNumber) {
        [self.navigationItem setHidesBackButton:NO];
        [self.racerNumberField becomeFirstResponder];
    }
    else if ([self.currentState integerValue] == DCBCheckpointControlStatePickJobNumber) {
        [self.jobNumberField setText:@""];
        [self.jobNumberField becomeFirstResponder];
    }
    else if ([self.currentState integerValue] == DCBCheckpointControlStateDropNumber) {
        [self.confirmCodeField setText:@""];
        [self.confirmCodeField becomeFirstResponder];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
    }
}

#pragma mark lookup Racer
- (IBAction)lookupRacer:(id)sender
{
    if ([[self.racerNumberField text] length] == 0) {
        return;
    }
    
    NSNumber *racerNumber = @([[self.racerNumberField text] integerValue]);
    [[TWMessageBarManager sharedInstance] hideAll];
    [self showLoadingHUD];
    [[DCBAPIManager sharedManager] getRacerWithRacerNumber:racerNumber success:^(DCBRacer *racer) {
        self.currentRacer = racer;
        [self changeToControlState:DCBCheckpointControlStatePickOrDrop hideMessageBar:YES];
        [self.racerNumberField setText:@""];
        [self hideLoadingHUD];
        [self.racerNameLabel setText:[self.currentRacer displayName]];
    } failure:^(NSError *error) {
        [self hideLoadingHUD];
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Find Racer"
                                                       description:@"Cannot find racer. Please try again"
                                                              type:TWMessageBarMessageTypeError
         ];
        [self.racerNumberField setText:@""];
        [self.racerNumberField becomeFirstResponder];
    }];
}

#pragma mark Pick or Drop
- (IBAction)wrongRacer:(id)sender
{
    self.currentRacer = nil;
    [self changeToControlState:DCBCheckpointControlStateRacerNumber hideMessageBar:YES];
}

- (IBAction)pick:(id)sender
{
    self.transactionType = DCBTransactionTypePick;
    [self changeToControlState:DCBCheckpointControlStatePickJobNumber hideMessageBar:YES];
}

- (IBAction)drop:(id)sender
{
    self.transactionType = DCBTransactionTypeDrop;
    [self changeToControlState:DCBCheckpointControlStateDropNumber hideMessageBar:YES];
}

#pragma mark Pick
- (IBAction)jobNumberEnter:(id)sender
{
    [[TWMessageBarManager sharedInstance] hideAll];
    [self showLoadingHUD];
    [[DCBAPIManager sharedManager] racerNumber:self.currentRacer.racerNumber
                            pickupAtCheckpoint:self.currentCheckpoint.checkpointNumber
                                     jobNumber:@([[self.jobNumberField text] integerValue])
                                       success:^(NSString *confirmCode) {
                                           [self hideLoadingHUD];
                                           [self.jobNumberField setText:@""];
                                           [self.confirmCodeLabel setText:confirmCode];
                                           [self updateLastConfirmCode:confirmCode racer:self.currentRacer];
                                           [self changeToControlState:DCBCheckpointControlStatePickConfirm hideMessageBar:YES];
                                       }
                                    inputError:^(NSString *errorTitle, NSString *errorDescription) {
                                        [self hideLoadingHUD];
                                        [[TWMessageBarManager sharedInstance] showMessageWithTitle:errorTitle
                                                                                       description:errorDescription
                                                                                              type:TWMessageBarMessageTypeError
                                         ];

                                    }
                                       failure:^(NSError *error) {
                                           [self hideLoadingHUD];
                                       }];
}

- (IBAction)cancelJobNumberEntry:(id)sender
{
    [self changeToControlState:DCBCheckpointControlStatePickOrDrop hideMessageBar:YES];
}

#pragma mark Pick Confirm
- (IBAction)nextRacer:(id)sender
{
    [self changeToControlState:DCBCheckpointControlStateRacerNumber hideMessageBar:YES];
}

#pragma mark Drop
- (IBAction)confirmCodeEnter:(id)sender
{
    [self showLoadingHUD];
    [[DCBAPIManager sharedManager] racerNumber:self.currentRacer.racerNumber
                           dropOffAtCheckpoint:self.currentCheckpoint.checkpointNumber
                                   confirmCode:@([[self.confirmCodeField text] integerValue])
                                                  success:^{
                                                      [self hideLoadingHUD];
                                                      NSString *successMessage = [NSString stringWithFormat:@"%@ successfully dropped off package with confirm code %@", [self.currentRacer racerNumber], [self.confirmCodeField text]];
                                                      [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Success!"
                                                                                                     description:successMessage
                                                                                                            type:TWMessageBarMessageTypeSuccess
                                                       ];
                                                      [self changeToControlState:DCBCheckpointControlStateRacerNumber hideMessageBar:NO];
                                                      [self flashColor:[UIColor greenColor]];

                                                  }
                                                  inputError:^(NSString *errorTitle, NSString *errorDescription) {
                                                      [self hideLoadingHUD];
                                                      [[TWMessageBarManager sharedInstance] showMessageWithTitle:errorTitle
                                                                                                     description:errorDescription
                                                                                                            type:TWMessageBarMessageTypeError
                                                       ];
                                                  }
                                                  failure:^(NSError *error) {
                                                      [self hideLoadingHUD];
                                                  }];
}

- (IBAction)cancelConfirmCode:(id)sender
{
    [self changeToControlState:DCBCheckpointControlStatePickOrDrop hideMessageBar:YES];
}

#pragma mark HUD
- (void)showLoadingHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
}

- (void)hideLoadingHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)flashColor:(UIColor *)color
{
    UIColor *originalColor = [self.view backgroundColor];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setBackgroundColor:color];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view setBackgroundColor:originalColor];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)updateLastConfirmCode:(NSString *)code racer:(DCBRacer *)racer
{
    if (!self.lastConfirmCode) {
        UIBarButtonItem *last = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rewind"] style:UIBarButtonItemStylePlain target:self action:@selector(showLastConfirmCode:)];
        [self.navigationItem setRightBarButtonItem:last];
    }
    
    self.lastConfirmCode = code;
    self.lastRacer = racer;
}

- (IBAction)showLastConfirmCode:(id)sender
{
    NSString *lastMessage = [NSString stringWithFormat:@"Racer #%@ (%@)'s confirm code was %@", self.lastRacer.racerNumber, self.lastRacer.firstName, self.lastConfirmCode];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Last Drop Confirm Code"
                                                   description:lastMessage
                                                          type:TWMessageBarMessageTypeInfo
     ];
}

@end
