//
//  SSFilterableDataSource.h
//  ExampleSSDataSources
//
//  Created by Jonathan Hersh on 8/25/13.
//  Copyright (c) 2013 Splinesoft. All rights reserved.
//

#import "SSBaseDataSource.h"

/**
 * A filterable data source automatically creates and manages a
 * UISearchDisplayController for you.
 * You need only to manage a searching block.
 */

@protocol SSDataSourcesSearcher;

@interface SSFilterableDataSource : SSBaseDataSource

#pragma mark - Searching

@property (nonatomic, assign) id <SSDataSourcesSearcher> dataSourceSearcher;

/**
 * Current searching status. Read-only.
 */
@property (nonatomic, readonly) BOOL isSearching;

/**
 * Optional delay, in seconds, to wait after a keystroke before beginning a search.
 * For example, if you're doing a search that requires a network request, this can
 * help cut down on network operations.
 * Defaults to 0.0f.
 */
@property (nonatomic, assign) CGFloat searchDelay;

/**
 * Start searching.
 * @param animated - whether to animate the search
 * @param viewcontroller - the view controller managing the display of the objects being searched
 */
- (void) startSearchingAnimated:(BOOL)animated withSearchBar:(UISearchBar *)searchBar inViewController:(UIViewController *)viewcontroller;

/**
 * Stop searching.
 */
- (void) stopSearchingAnimated:(BOOL)animated;

@end

/////////

typedef void (^SSFilteredResultsBlock) (NSArray *);

@protocol SSDataSourcesSearcher <NSObject>

@optional

- (void) dataSource:(SSFilterableDataSource *)dataSource
  didSearchWithTerm:(NSString *)term
       resultsBlock:(SSFilteredResultsBlock)resultsBlock;

- (void) dataSource:(SSFilterableDataSource *)dataSource didSelectSearchResult:(id)result;

@end