//
//  TASettingsViewController.m
//  TestApp
//
//  Created by Sergey Kovalenko on 3/13/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import "TASettingsViewController.h"
#import "TAAppDelegate.h"
#import "TACoreDataStack.h"

@interface TASettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;

@end

@implementation TASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iCloudSwitch.on = [[[TAAppDelegate appdelegate]coreDataStack] iCloudEnabled];
}

- (IBAction)enableiCloud:(id)sender {
    if (self.iCloudSwitch.isOn) {
        [[[TAAppDelegate appdelegate]coreDataStack] migratePersistentStoreToiCloudStoreWithError:nil];
    } else {
      [[[TAAppDelegate appdelegate]coreDataStack] migratePersistentStoreToLocalStoreWithError:nil];
    }
}

- (IBAction)removeiCloudData:(id)sender {

}

@end
