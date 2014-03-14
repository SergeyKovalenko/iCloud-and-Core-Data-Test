//
//  TASettingsViewController.m
//  TestApp
//
//  Created by Sergey Kovalenko on 3/13/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import "TASettingsViewController.h"
#import "TACoreDataStack.h"

@interface TASettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *iCloudSwitch;

@end

@implementation TASettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iCloudSwitch.on = [[TACoreDataStack currentStack] iCloudEnabled];
}

- (IBAction)enableiCloud:(id)sender {
    if (self.iCloudSwitch.isOn) {
        [[TACoreDataStack currentStack] migratePersistentStoreToiCloudStoreWithError:nil];
    } else {
        [[TACoreDataStack currentStack] migratePersistentStoreToLocalStoreWithError:nil];
    }
}

- (IBAction)removeiCloudData:(id)sender {
    if ([[TACoreDataStack currentStack] iCloudEnabled]) {
        [TACoreDataStack removeiCliudDataWithError:nil];
        self.iCloudSwitch.on = [[TACoreDataStack currentStack] iCloudEnabled];
    }
}

@end
