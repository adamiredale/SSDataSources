//
//  SSFilterableDataSource.m
//  ExampleSSDataSources
//
//  Created by Jonathan Hersh on 8/25/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSFilterableDataSource.h"

@interface SSFilterableDataSource () <UISearchDisplayDelegate, UISearchBarDelegate>

- (void) executeSearchWithTerm:(NSString *)term;

@end

@implementation SSFilterableDataSource {
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *searchResults;
}

@synthesize searchBar, searchDelay;

#pragma mark - Init

- (instancetype)init {
    if( ( self = [super init] ) ) {
        self.searchDelay = 0.0f;
    }
    
    return self;
}

- (void)dealloc {
    self.searchBar = nil;
}

#pragma mark - Searching

- (BOOL)isSearching {
    return [searchDisplayController isActive];
}

- (void)startSearchingAnimated:(BOOL)animated inViewController:(UIViewController *)viewcontroller {
    if( [searchDisplayController isActive] )
        return;

    if( !searchBar ) {
        searchBar = [[UISearchBar alloc] initWithFrame:(CGRect) {
            0, 0,
            CGRectGetWidth(self.tableView.bounds),
            44
        }];
        
        searchBar.delegate = self;
    }

    if( !searchDisplayController ) {
        searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                    contentsController:viewcontroller];
    }
    
    [searchDisplayController setActive:YES
                              animated:animated];
}

- (void)stopSearchingAnimated:(BOOL)animated {
    if( ![searchDisplayController isActive] )
        return;
    
    [searchBar resignFirstResponder];
    
    [searchDisplayController setActive:NO animated:animated];
}

- (void)executeSearchWithTerm:(NSString *)term {
    
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
    
    self.tableView = tableView; // TBD
    
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)ASearchBar {
    ASearchBar.text = nil;
    [ASearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)ASearchBar {
    [ASearchBar resignFirstResponder];
}

@end
