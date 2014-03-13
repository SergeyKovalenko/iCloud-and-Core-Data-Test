//
//  TAAppDelegate.m
//  TestApp
//
//  Created by Sergey Kovalenko on 3/11/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import "TAAppDelegate.h"
#import "TACoreDataStack.h"
#import "TAMasterViewController.h"

@implementation TAAppDelegate

@synthesize coreDataStack = _coreDataStack;

+ (TAAppDelegate *)appdelegate {
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _coreDataStack = [TACoreDataStack new];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.coreDataStack saveContext];
}




@end
