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
    
    [[_currentStateView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *view;
    switch (state) {
        case DCBCheckpointControlStateRacerNumber:
            view = _racerNumberView;
            break;
        case DCBCheckpointControlStatePickOrDrop:
            view = _pickOrDropView;
            break;
        case DCBCheckpointControlStatePickJobNumber:
            view = _pickJobNumberView;
            break;
        case DCBCheckpointControlStatePickConfirm:
            view = _pickConfirmView;
            break;
        case DCBCheckpointControlStateDropNumber:
            view = _dropConfirmCodeView;
            break;
    }
    [_currentStateView addSubview:view];
    [self setCurrentState:@(state)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([_currentState integerValue] == DCBCheckpointControlStateRacerNumber) {
        [self.navigationItem setHidesBackButton:NO];
        [_racerNumberField becomeFirstResponder];
    }
    else if ([_currentState integerValue] == DCBCheckpointControlStatePickJobNumber) {
        [_jobNumberField setText:@""];
        [_jobNumberField becomeFirstResponder];
    }
    else if ([_currentState integerValue] == DCBCheckpointControlStateDropNumber) {
        [_confirmCodeField setText:@""];
        [_confirmCodeField becomeFirstResponder];
    }
    else {
        [self.navigationItem setHidesBackButton:YES];
    }
}

#pragma mark lookup Racer
- (IBAction)lookupRacer:(id)sender
{
    if ([[_racerNumberField text] length] == 0) {
        return;
    }
    
    NSNumber *racerNumber = @([[_racerNumberField text] integerValue]);
    [[TWMessageBarManager sharedInstance] hideAll];
    [self showLoadingHUD];
    [[DCBAPIManager sharedManager] getRacerWithRacerNumber:racerNumber success:^(DCBRacer *racer) {
        _currentRacer = racer;
        [self changeToControlState:DCBCheckpointControlStatePickOrDrop hideMessageBar:YES];
        [_racerNumberField setText:@""];
        [self hideLoadingHUD];
        [_racerNameLabel setText:[_currentRacer displayName]];
    } failure:^(NSError *error) {
        [self hideLoadingHUD];
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Find Racer"
                                                       description:@"Cannot find racer. Please try again"
                                                              type:TWMessageBarMessageTypeError
         ];
        [_racerNumberField setText:@""];
        [_racerNumberField becomeFirstResponder];
    }];
}

#pragma mark Pick or Drop
- (IBAction)wrongRacer:(id)sender
{
    _currentRacer = nil;
    [self changeToControlState:DCBCheckpointControlStateRacerNumber hideMessageBar:YES];
}

- (IBAction)pick:(id)sender
{
    _transactionType = DCBTransactionTypePick;
    [self changeToControlState:DCBCheckpointControlStatePickJobNumber hideMessageBar:YES];
}

- (IBAction)drop:(id)sender
{
    _transactionType = DCBTransactionTypeDrop;
    [self changeToControlState:DCBCheckpointControlStateDropNumber hideMessageBar:YES];
}

#pragma mark Pick
- (IBAction)jobNumberEnter:(id)sender
{
    [[TWMessageBarManager sharedInstance] hideAll];
    [self showLoadingHUD];
    [[DCBAPIManager sharedManager] racerNumber:_currentRacer.racerNumber
                            pickupAtCheckpoint:_currentCheckpoint.checkpointNumber
                                     jobNumber:@([[_jobNumberField text] integerValue])
                                       success:^(NSString *confirmCode) {
                                           [self hideLoadingHUD];
                                           [_jobNumberField setText:@""];
                                           [_confirmCodeLabel setText:confirmCode];
                                           [self updateLastConfirmCode:confirmCode racer:_currentRacer];
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
    [[DCBAPIManager sharedManager] racerNumber:_currentRacer.racerNumber
                           dropOffAtCheckpoint:_currentCheckpoint.checkpointNumber
                                   confirmCode:@([[_confirmCodeField text] integerValue])
                                                  success:^{
                                                      [self hideLoadingHUD];
                                                      NSString *successMessage = [NSString stringWithFormat:@"%@ successfully dropped off package with confirm code %@", [_currentRacer racerNumber], [_confirmCodeField text]];
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
    if (!_lastConfirmCode) {
        UIBarButtonItem *last = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rewind"] style:UIBarButtonItemStylePlain target:self action:@selector(showLastConfirmCode:)];
        [self.navigationItem setRightBarButtonItem:last];
    }
    
    _lastConfirmCode = code;
    _lastRacer = racer;
}

- (IBAction)showLastConfirmCode:(id)sender
{
    NSString *lastMessage = [NSString stringWithFormat:@"Racer #%@ (%@)'s confirm code was %@", _lastRacer.racerNumber, _lastRacer.firstName, _lastConfirmCode];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Last Drop Confirm Code"
                                                   description:lastMessage
                                                          type:TWMessageBarMessageTypeInfo
     ];
}

@end
