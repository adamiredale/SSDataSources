SSDataSources
=============

[![Build Status](https://travis-ci.org/splinesoft/SSDataSources.png?branch=master)](https://travis-ci.org/splinesoft/SSDataSources) 

Simple data sources for your `UITableView` and `UICollectionView` because proper developers don't repeat themselves. :)

No doubt you've done the `tableView:cellForRowAtIndexPath:` and `tableView:numberOfRowsInSection:` and `collectionView:cellForItemAtIndexPath:` and `collectionView:numberOfItemsInSection:` dances many times before. You may also have updated your data and forgotten to update the table or collection view. Whoops -- crash! Is there a better way?

`SSDataSources` is a collection of objects that conform to `UITableViewDataSource` and `UICollectionViewDataSource`. This is my own implementation of ideas featured in [objc.io's wonderful first issue](http://www.objc.io/issue-1/table-views.html).

`SSDataSources` powers single-section, multi-section, and Core Data-backed tables in my app [MUDRammer - a modern MUD client for iPhone and iPad](https://itunes.apple.com/us/app/mudrammer-a-modern-mud-client/id597157072?mt=8). Let me know if you use it in your app!

## Install

Install with [Cocoapods](http://cocoapods.org). Add to your podfile:

```
pod 'SSDataSources', :head # YOLO
```

## Samples

All the tables and collection views in the `Example` project are built with `SSDataSources`.

## Array Data Source

`SSArrayDataSource` powers a table or collection view with a single section. See `SSArrayDataSource.h` for more details.

Check out the example project for sample table and collection views that use the array data source.


```objc
@interface WizardicTableViewController : UITableViewController

@property (nonatomic, strong) SSArrayDataSource *wizardDataSource;

@end

@implementation WizardicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _wizardDataSource = [[SSArrayDataSource alloc] initWithItems:
                         @[ @"Merlyn", @"Gandalf", @"Melisandre" ]];

	// SSDataSources creates your cell and calls
	// this configure block for each cell with 
	// the object being presented in that cell,
	// the parent table or collection view,
	// and the index path at which the cell appears.
    _wizardDataSource.cellConfigureBlock = ^(SSBaseTableCell *cell, 
                                            NSString *wizard,
                                            UITableView *tableView,
                                            NSIndexPath *indexPath) {
        cell.textLabel.text = wizard;
    };
    
    // Set the tableView property and the data source will perform
    // insert/reload/delete calls on the table as its data changes.
    // This also assigns the table's `dataSource` property.
    _wizardDataSource.tableView = self.tableView;
}
@end
```

That's it - you're done! 

Perhaps your data changes:

```objc
// Optional - row animation for table updates.
wizardDataSource.rowAnimation = UITableViewRowAnimationFade;
	
// Automatically inserts two new cells at the end of the table.
[wizardDataSource appendItems:@[ @"Saruman", @"Alatar" ]];

// Update the fourth item; reloads the fourth row.
[wizardDataSource replaceItemAtIndex:3 withItem:@"Pallando"];

// Sorry Merlyn :(
[wizardDataSource moveItemAtIndex:0 toIndex:1];
	
// Remove the second and third cells.
[wizardDataSource removeItemsInRange:NSMakeRange( 1, 2 )];
```

Perhaps you have custom table cell classes or multiple classes in the same table:

```objc
wizardDataSource.cellCreationBlock = ^id(NSString *wizard, 
                                         UITableView *tableView, 
                                         NSIndexPath *indexPath) {
	if ([wizard isEqualToString:@"Gandalf"]) {
		return [MiddleEarthWizardCell cellForTableView:tableView];
	} else if ([wizard isEqualToString:@"Merlyn"]) {
		return [ArthurianWizardCell cellForTableView:tableView];
    }
};

```

Your view controller should continue to implement `UITableViewDelegate`. `SSDataSources` can help there too:

```objc
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *wizard = [wizardDataSource itemAtIndexPath:indexPath];
	
	// do something with `wizard`
}
```

## Sectioned Data Source

`SSSectionedDataSource` powers a table or collection view with multiple sections. Each section is modeled with an `SSSection` object, which stores the section's items and a few other configurable bits. See `SSSectionedDataSource.h` and `SSSection.h` for more details.

Check out the example project for a sample table that uses the sectioned data source.

```objc
@interface ElementalTableViewController : UITableViewController

@property (nonatomic, strong) SSSectionedDataSource *elementDataSource;

@end

@implementation ElementalTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Let's start with one section
    _elementDataSource = [[SSSectionedDataSource alloc] initWithItems:@[ @"Earth" ]];

    _elementDataSource.cellConfigureBlock = ^(SSBaseTableCell *cell, 
                                              NSString *element,
                                              UITableView *tableView,
                                              NSIndexPath *indexPath) {
         cell.textLabel.text = element;
    };
    
    // Setting the tableView property automatically updates 
    // the table in response to data changes.
    // This also sets the table's `dataSource` property.
    _elementDataSource.tableView = self.tableView;
}
@end
```

`SSSectionedDataSource` has you covered if your data changes:
 
```objc
// Animation for table updates
elementDataSource.rowAnimation = UITableViewRowAnimationFade;

// Add some new sections
[elementDataSource appendSection:[SSSection sectionWithItems:@[ @"Fire" ]]];
[elementDataSource appendSection:[SSSection sectionWithItems:@[ @"Wind" ]]];
[elementDataSource appendSection:[SSSection sectionWithItems:@[ @"Water" ]]];
[elementDataSource appendSection:[SSSection sectionWithItems:@[ @"Heart", @"GOOOO PLANET!" ]]];

// Are you 4 srs, heart?
[elementDataSource removeSectionAtIndex:([elementDataSource numberOfSections] - 1)];
```

## Core Data

You're a modern wo/man-about-Internet and sometimes you want to present a `UITableView` or `UICollectionView` backed by a core data fetch request or fetched results controller. `SSDataSources` has you covered with `SSCoreDataSource`, featured here with a cameo by [MagicalRecord](https://github.com/magicalpanda/MagicalRecord).

```objc
@interface SSCoreDataTableViewController : UITableViewController

@property (nonatomic, strong) SSCoreDataSource *dataSource;

@end

@implementation SSCoreDataTableViewController

- (void) viewDidLoad {
	[super viewDidLoad];
	
	NSFetchRequest *triggerFetch = [Trigger MR_requestAllSortedBy:[Trigger defaultSortField]
                                                        ascending:[Trigger defaultSortAscending]];
   
    _dataSource = [[SSCoreDataSource alloc] initWithFetchRequest:worldFetch
                                                       inContext:[NSManagedObjectContext 
                                                                  MR_defaultContext]
                                              sectionNameKeyPath:nil];
                                                 
    _dataSource.cellConfigureBlock = ^(SSBaseTableCell *cell, 
                                       Trigger *trigger, 
                                       UITableView *tableView,
                                       NSIndexPath *indexPath ) {
         cell.textLabel.text = trigger.name;
    };
    
    // SSCoreDataSource conforms to NSFetchedResultsControllerDelegate.
    // Set the `tableView` property to automatically update the table 
    // after changes in the data source's managed object context.
    // This also sets the tableview's `dataSource`.
    _dataSource.tableView = self.tableView;
    
    // Optional - row animation to use for update events.
    _dataSource.rowAnimation = UITableViewRowAnimationFade;
    
    // Optional - permissions for editing and moving
    _dataSource.tableActionBlock = ^BOOL(SSCellActionType actionType,
                                         UITableView *tableView,
                                         NSIndexPath *indexPath) {
         
         // Disallow moving, allow editing
         return actionType == SSCellActionTypeEdit;
    };
    
    // Optional - handle managed object deletion
    _dataSource.tableDeletionBlock = ^(SSCoreDataSource *aDataSource,
                                       UITableView *tableView,
                                       NSIndexPath *indexPath) {
                                      
        Trigger *myObject = [aDataSource itemAtIndexPath:indexPath];
        
        // SSCoreDataSource conforms to NSFetchedResultsControllerDelegate,
        // so saving the object's context will automatically update the table.
        [myObject deleteInContext:myObject.managedObjectContext];
        [myObject.managedObjectContext MR_saveToPersistentStoreWithCompletion:nil];
    };
}
@end
```

## Thanks!

`SSDataSources` is a [@jhersh](https://github.com/jhersh) production -- ([electronic mail](mailto:jon@her.sh) | [@jhersh](https://twitter.com/jhersh))
