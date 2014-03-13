//
//  TAAppDelegate.h
//  TestApp
//
//  Created by Sergey Kovalenko on 3/11/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TACoreDataStack;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) TACoreDataStack *coreDataStack;


+ (TAAppDelegate *)appdelegate;


@end
