//
//  SSFilterableDataSource.m
//  ExampleSSDataSources
//
//  Created by Jonathan Hersh on 8/25/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSDataSources.h"

@interface SSFilterableDataSource () <UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate>

- (void) executeSearchWithTerm:(NSString *)term;

@end

@implementation SSFilterableDataSource {
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *resultIndexes;
    
    SSArrayDataSource *resultsDataSource;
}

@synthesize searchDelay, dataSourceSearcher;

#pragma mark - Init

- (instancetype)init {
    if( ( self = [super init] ) ) {
        self.searchDelay = 0.0f;
    }
    
    return self;
}

- (void)dealloc {
    searchDisplayController = nil;
    resultsDataSource = nil;
    
    self.dataSourceSearcher = nil;
}

#pragma mark - Searching

- (BOOL)isSearching {
    return [searchDisplayController isActive];
}

- (void)startSearchingAnimated:(BOOL)animated withSearchBar:(UISearchBar *)searchBar inViewController:(UIViewController *)viewcontroller {
    if( [searchDisplayController isActive] )
        return;

    if( !searchDisplayController ) {
        searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                    contentsController:viewcontroller];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate = self;
    }
    
    [searchDisplayController setActive:YES
                              animated:animated];
}

- (void)stopSearchingAnimated:(BOOL)animated {
    if( ![searchDisplayController isActive] )
        return;
    
    [searchDisplayController.searchBar resignFirstResponder];
    
    [searchDisplayController setActive:NO animated:animated];
}

- (void)executeSearchWithTerm:(NSString *)term {
    if( [self.dataSourceSearcher respondsToSelector:@selector(dataSource:didSearchWithTerm:resultsBlock:)] ) {
        SSFilteredResultsBlock resultsBlock = ^(NSArray *results) {
            NSLog(@"got results %@", results);
        };
        
        [self.dataSourceSearcher dataSource:self
                          didSearchWithTerm:term
                               resultsBlock:resultsBlock];
    }
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    if( [searchString length] == 0 ) {
        // clear items?
        return YES;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(executeSearchWithTerm:)
               withObject:searchString
               afterDelay:self.searchDelay];
    
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller
 willShowSearchResultsTableView:(UITableView *)tableView {
    
    resultsDataSource.tableView = tableView;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object;
    
    if( [self.dataSourceSearcher respondsToSelector:@selector(dataSource:didSelectSearchResult:)] )
        [self.dataSourceSearcher dataSource:self
                      didSelectSearchResult:object];
}

@end
