//
//  TAMasterViewController.h
//  TestApp
//
//  Created by Sergey Kovalenko on 3/11/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TADetailViewController;

#import <CoreData/CoreData.h>

@interface TAMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TADetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
