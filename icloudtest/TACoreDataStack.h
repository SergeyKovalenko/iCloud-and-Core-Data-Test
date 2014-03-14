//
//  TACoreDataStack.h
//  icloudtest
//
//  Created by Sergey Kovalenko on 3/13/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface TACoreDataStack : NSObject

- (instancetype)initWithPersistentStoreURL:(NSURL*)URL;

+ (instancetype)currentStack;

@property (readonly, strong, nonatomic) NSURL *persistentStoreURL;

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainContext;

@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (BOOL)iCloudEnabled;

- (BOOL)migratePersistentStoreToiCloudStoreWithError:(NSError **)error;

- (BOOL)migratePersistentStoreToLocalStoreWithError:(NSError **)error;

+ (BOOL)removeiCliudDataWithError:(NSError **)error;

@end
