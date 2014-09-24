//
//  DCBArrayTableDataSource.h
//  MlpsNaccc
//
//  Derived from objc.io Issue #1 Lighter View Controllers
//
//

#import <Foundation/Foundation.h>

typedef void (^DCBTableViewConfigureBlock)(id cell, id item);

@interface DCBArrayTableDataSource : NSObject <UITableViewDataSource>

- (instancetype)initWithArray:(NSArray *)array cellIdentifier:(NSString *)identifier configureCellBlock:(DCBTableViewConfigureBlock)block;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfItems;

@end
