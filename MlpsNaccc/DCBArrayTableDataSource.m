//
//  DCBArrayTableDataSource.m
//  MlpsNaccc
//
//  Derived from objc.io Issue #1 Lighter View Controllers
//
//

#import "DCBArrayTableDataSource.h"

@interface DCBArrayTableDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) DCBTableViewConfigureBlock configureBlock;

@end

@implementation DCBArrayTableDataSource

- (instancetype)initWithArray:(NSArray *)array cellIdentifier:(NSString *)identifier configureCellBlock:(DCBTableViewConfigureBlock)block
{
    self = [super init];
    if (self) {
        _items = array;
        _identifier = identifier;
        _configureBlock = block;
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return _items[indexPath.row];
}

- (NSInteger)numberOfItems
{
    return _items.count;
}

#pragma mark UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    _configureBlock(cell, item);
    return cell;
}

@end
