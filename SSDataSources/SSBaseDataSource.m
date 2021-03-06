//
//  SSBaseDataSource.m
//  SSDataSources
//
//  Created by Jonathan Hersh on 6/8/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSDataSources.h"

@interface SSBaseDataSource ()

@property (nonatomic, assign) UITableViewCellSeparatorStyle cachedSeparatorStyle;

- (void) _updateEmptyView;

@end

@implementation SSBaseDataSource

#pragma mark - init

- (instancetype)init {
    if ((self = [super init])) {
        self.cellClass = [SSBaseTableCell class];
        self.collectionViewSupplementaryElementClass = [SSBaseCollectionReusableView class];
        self.rowAnimation = UITableViewRowAnimationAutomatic;
    }
    
    return self;
}

- (void)dealloc {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    
    self.cellConfigureBlock = nil;
    self.cellCreationBlock = nil;
    self.collectionSupplementaryConfigureBlock = nil;
    self.collectionSupplementaryCreationBlock = nil;
    self.tableActionBlock = nil;
    self.tableDeletionBlock = nil;
}

#pragma mark - Base item access

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    // override me!
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSUInteger)numberOfItems {
    // override me!
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSUInteger)numberOfSections {
    // override me!
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section {
    // override me!
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Custom Animations

- (void)performAnimations:(void (^)(void))animations
                 duration:(NSTimeInterval)duration
               completion:(void (^)(void))completion {
    
    if (!animations) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.tableView beginUpdates];
                         animations();
                         [self.tableView endUpdates];
                     }];
    
    [CATransaction commit];
}

#pragma mark - Common

- (void)configureCell:(id)cell
              forItem:(id)item
           parentView:(id)parentView
            indexPath:(NSIndexPath *)indexPath {
    
    if (self.cellConfigureBlock)
        self.cellConfigureBlock( cell, item, parentView, indexPath );
}

#pragma mark - UITableViewDataSource

- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
        
    if (tableView) {
        tableView.dataSource = self;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    id item = [self itemAtIndexPath:indexPath];
    id cell;
    
    if (self.cellCreationBlock)
        cell = self.cellCreationBlock(item, tv, indexPath);
    else
        cell = [self.cellClass cellForTableView:tv];

    [self configureCell:cell
                forItem:item
             parentView:tv
              indexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableActionBlock) {
        return self.tableActionBlock(SSCellActionTypeMove,
                                     tv,
                                     indexPath);
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableActionBlock) {
        return self.tableActionBlock(SSCellActionTypeEdit,
                                     tv,
                                     indexPath);
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tv
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableDeletionBlock) {
        self.tableDeletionBlock(self,
                                tv,
                                indexPath);
    }
}

#pragma mark - UICollectionViewDataSource

- (void)setCollectionView:(UICollectionView *)collectionView {
    _collectionView = collectionView;
    
    if (collectionView)
        collectionView.dataSource = self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    id cell;
    
    if (self.cellCreationBlock)
        cell = self.cellCreationBlock(item, cv, indexPath);
    else
        cell = [self.cellClass cellForCollectionView:cv
                                           indexPath:indexPath];

    [self configureCell:cell
                forItem:item
             parentView:cv
              indexPath:indexPath];

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  
    return [self numberOfItemsInSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *supplementaryView;
    
    if (self.collectionSupplementaryCreationBlock)
        supplementaryView = self.collectionSupplementaryCreationBlock(kind, cv, indexPath);
    else
        supplementaryView = [self.collectionViewSupplementaryElementClass
                             supplementaryViewForCollectionView:cv
                             kind:kind
                             indexPath:indexPath];
    
    if (self.collectionSupplementaryConfigureBlock)
        self.collectionSupplementaryConfigureBlock(supplementaryView, kind, cv, indexPath);
    
    return supplementaryView;
}

#pragma mark - Empty Views

- (void)setEmptyView:(UIView *)emptyView {
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
    
    _emptyView = emptyView;
    
    _emptyView.hidden = YES;
    
    [self _updateEmptyView];
}

- (void)_updateEmptyView {
    if (!self.emptyView) {
        return;
    }
    
    UIScrollView *targetView = (self.tableView ?: self.collectionView);
    
    if (!targetView) {
        return;
    }
    
    if (self.emptyView.superview != targetView) {
        [targetView addSubview:self.emptyView];
    }
    
    BOOL shouldShowEmptyView = ([self numberOfItems] == 0);
    BOOL isShowingEmptyView = !self.emptyView.hidden;
    
    if (shouldShowEmptyView == isShowingEmptyView) {
        return;
    }
    
    if (shouldShowEmptyView) {
        self.cachedSeparatorStyle = self.tableView.separatorStyle;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (CGRectEqualToRect(self.emptyView.frame, CGRectZero)) {
            CGRect frame = UIEdgeInsetsInsetRect(targetView.bounds, targetView.contentInset);
            
            if (self.tableView.tableHeaderView) {
                frame.size.height -= CGRectGetHeight(self.tableView.tableHeaderView.frame);
            }
            
            [self.emptyView setFrame:frame];
        }
        
        self.emptyView.autoresizingMask = targetView.autoresizingMask;
    } else {
        self.tableView.separatorStyle = self.cachedSeparatorStyle;
    }
    
    self.emptyView.hidden = !shouldShowEmptyView;
    
    // Reloading seems to work around an awkward delay where the empty view
    // is not immediately visible but the separator lines still are
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

#pragma mark - UITableView/UICollectionView Operations

- (void)insertCellsAtIndexPaths:(NSArray *)indexPaths {
    [_tableView insertRowsAtIndexPaths:indexPaths
                      withRowAnimation:self.rowAnimation];
    
    [_collectionView insertItemsAtIndexPaths:indexPaths];
    
    [self _updateEmptyView];
}

- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths {
    [_tableView deleteRowsAtIndexPaths:indexPaths
                      withRowAnimation:self.rowAnimation];
    
    [_collectionView deleteItemsAtIndexPaths:indexPaths];
    
    [self _updateEmptyView];
}

- (void)reloadCellsAtIndexPaths:(NSArray *)indexPaths {
    [_tableView reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:self.rowAnimation];
    
    [_collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)moveCellAtIndexPath:(NSIndexPath *)index1 toIndexPath:(NSIndexPath *)index2 {
    [_tableView moveRowAtIndexPath:index1
                       toIndexPath:index2];
    
    [_collectionView moveItemAtIndexPath:index1
                             toIndexPath:index2];
}

- (void)moveSectionAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 {
    [_tableView moveSection:index1
                  toSection:index2];
    
    [_collectionView moveSection:index1
                       toSection:index2];
}

- (void)insertSectionsAtIndexes:(NSIndexSet *)indexes {
    [_tableView insertSections:indexes
              withRowAnimation:self.rowAnimation];
    
    [_collectionView insertSections:indexes];
    
    [self _updateEmptyView];
}

- (void)deleteSectionsAtIndexes:(NSIndexSet *)indexes {
    [_tableView deleteSections:indexes
              withRowAnimation:self.rowAnimation];
    
    [_collectionView deleteSections:indexes];
    
    [self _updateEmptyView];
}

- (void)reloadData {
    [self.tableView reloadData];
    [self.collectionView reloadData];
    
    [self _updateEmptyView];
}

#pragma mark - NSIndexPath helpers

+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes
                              inSection:(NSUInteger)section {
    
    NSMutableArray *ret = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [ret addObject:[NSIndexPath indexPathForRow:index inSection:section]];
    }];
    
    return ret;
}

+ (NSArray *)indexPathArrayWithRange:(NSRange)range
                           inSection:(NSUInteger)section {
    
    NSMutableArray *ret = [NSMutableArray array];
    
    for (NSUInteger i = range.location; i < NSMaxRange(range); i++)
        [ret addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    
    return ret;
}

@end
