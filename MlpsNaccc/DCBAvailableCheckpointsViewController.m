//
//  DCBAvailableCheckpointsViewController.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import "DCBAvailableCheckpointsViewController.h"

#import "DCBAPIManager.h"
#import "DCBArrayTableDataSource.h"
#import "DCBCheckpoint.h"
#import "DCBCheckpointControlViewController.h"

@interface DCBAvailableCheckpointsViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) DCBArrayTableDataSource *dataSource;

- (void)setupTableView;
- (void)setupLogout;
- (void)setupRefreshControl;
- (void)reloadAvailableCheckpoints;
- (void)logout:(id)sender;

@end

@implementation DCBAvailableCheckpointsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupLogout];
    [self setupTableView];
    [self setupRefreshControl];
    [self reloadAvailableCheckpoints];
    [self setTitle:@"Your Checkpoints"];
}

- (void)setupLogout
{
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    [self.navigationItem setLeftBarButtonItem:logout];
}

- (void)setupTableView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView setDelegate:self];
}

- (void)setupRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadAvailableCheckpoints) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)reloadAvailableCheckpoints
{
    [self.refreshControl beginRefreshing];
    [[DCBAPIManager sharedManager] getListOfCheckpoints:^(NSArray *checkpoints) {
        self.dataSource = [[DCBArrayTableDataSource alloc] initWithArray:checkpoints
                                                                      cellIdentifier:@"cell"
                                                                  configureCellBlock:^(id cell, id item) {
                                                                      UITableViewCell *theCell = cell;
                                                                      DCBCheckpoint *checkpoint = item;
                                                                      theCell.textLabel.text = checkpoint.checkpointName;
                                                                  }];
        [self.tableView setDataSource:self.dataSource];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [self.dataSource numberOfItems]) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        DCBCheckpointControlViewController *vc = [[DCBCheckpointControlViewController alloc] initWithCheckpoint:[self.dataSource itemAtIndexPath:indexPath]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)logout:(id)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Logout?" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    [av show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView firstOtherButtonIndex]) {
        [[DCBAPIManager sharedManager] logout];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
