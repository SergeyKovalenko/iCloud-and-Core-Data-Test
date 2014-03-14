//
//  TACoreDataStack.m
//  icloudtest
//
//  Created by Sergey Kovalenko on 3/13/14.
//  Copyright (c) 2014 TestApp. All rights reserved.
//

#import "TACoreDataStack.h"

@interface TACoreDataStack ()
@property (nonatomic, strong) id ubiquityIdentityObserver;
@property (nonatomic, assign, getter = isiCloudEnable) BOOL iCloudEnable;
@end

@implementation TACoreDataStack

@synthesize backgroundContext = _backgroundContext;
@synthesize mainContext = _mainContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreURL = _persistentStoreURL;

#pragma mark - CoreData Stack

- (id)init {
    return [self initWithPersistentStoreURL:nil];
}

- (instancetype)initWithPersistentStoreURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        
        _persistentStoreURL = URL ?: [self storeURL];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
//        self.isiCloudEnable = [defaults boolForKey:@""]
        
        BOOL(^ubiquityIdentity)() = ^(){
            
            id currentiCloudToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
            BOOL iCloudEnabled = currentiCloudToken != nil;
            
            NSLog(@"ubiquityIdentityToken %@", iCloudEnabled ? [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken] : nil);
            
            if (iCloudEnabled) {
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken]
                                                          forKey:@"UbiquityIdentityToken"];
                
                __block NSURL *myUbiquityContainer;
                
                dispatch_async (dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    myUbiquityContainer = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                    if (myUbiquityContainer != nil) {
                        // Your app can write to the ubiquity container
                        NSLog(@"myUbiquityContainer %@",myUbiquityContainer);
                    }
                });
                
                [self registerForiCloudNotifications];
                
            } else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UbiquityIdentityToken"];
            }
            return iCloudEnabled;
        };
        
        
        if (!ubiquityIdentity()) {
            _ubiquityIdentityObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSUbiquityIdentityDidChangeNotification
                                                                                          object:nil
                                                                                           queue:nil
                                                                                      usingBlock:^(NSNotification *note) {
                                                                                          ubiquityIdentity();
                                                                                      }];
        }
    }
    
    return self;
}

- (NSURL *)storeURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataBase.sqlite"];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)mainContext {
    if (_mainContext != nil) {
        return _mainContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setParentContext:self.backgroundContext];
        [_mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    return _mainContext;
}

- (NSManagedObjectContext *)backgroundContext {
    if (_backgroundContext != nil) {
        return _backgroundContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundContext setPersistentStoreCoordinator:coordinator];
        [_backgroundContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    return _backgroundContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:[self storeURL]
                                                         options:nil
                                                           error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}


- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.mainContext;
    while (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        managedObjectContext = [managedObjectContext parentContext];
    }
}


# pragma mark - iCloud Support

- (NSDictionary *)storeOptions {
    return @{ NSPersistentStoreUbiquitousContentNameKey : @"icloudtest",
              NSPersistentStoreUbiquitousContentURLKey  :  @"icloudtestCDLogs"};
}

- (BOOL)iCloudEnabled {
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores firstObject];
    NSString *ubiquitousContentName = [store.options objectForKey:NSPersistentStoreUbiquitousContentNameKey];
    return  ubiquitousContentName.length && [[NSFileManager defaultManager] ubiquityIdentityToken] != nil;
}

- (BOOL)migratePersistentStoreToiCloudStoreWithError:(NSError *__autoreleasing *)error {
    BOOL migrated = NO;
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores firstObject];
    NSString *ubiquitousContentName = [store.options objectForKey:NSPersistentStoreUbiquitousContentNameKey];
    
    if (ubiquitousContentName.length == 0) {
        
        [self saveContext];
        
        NSError *internalError = error ? *error : nil;
        
        NSPersistentStore *newstore = [self.persistentStoreCoordinator migratePersistentStore:store
                                                                                        toURL:[self storeURL]
                                                                                      options:[self storeOptions]
                                                                                     withType:NSSQLiteStoreType
                                                                                        error:&internalError];
        
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), internalError);
        
       migrated = newstore && [[NSFileManager defaultManager] removeItemAtURL:store.URL
                                                                        error:&internalError];

        migrated = [self reloadStore:newstore
                         withOptions:[self storeOptions]
                               error:&internalError];

        NSLog(@"%@ %@", NSStringFromSelector(_cmd), internalError);

    } else if(error){
        *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                     code:101
                                 userInfo:@{NSLocalizedDescriptionKey : @"iCloude enabled for current persistent store."}];
    }
    return migrated;
}

- (BOOL)migratePersistentStoreToLocalStoreWithError:(NSError *__autoreleasing *)error {
    BOOL migrated = NO;
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores firstObject];
    NSString *ubiquitousContentName = [store.options objectForKey:NSPersistentStoreUbiquitousContentNameKey];
    
    if (ubiquitousContentName.length != 0) {
        
        [self saveContext];
        
        NSMutableDictionary *localStoreOptions = [[self storeOptions] mutableCopy];
        [localStoreOptions setObject:@YES forKey:NSPersistentStoreRemoveUbiquitousMetadataOption];
        
        NSError *internalError = error ? *error : nil;
        
        NSPersistentStore *newstore = [self.persistentStoreCoordinator migratePersistentStore:store
                                                                                        toURL:[self storeURL]
                                                                                      options:localStoreOptions
                                                                                     withType:NSSQLiteStoreType
                                                                                        error:&internalError];
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), internalError);
        
        migrated = newstore && [[NSFileManager defaultManager] removeItemAtURL:store.URL
                                                                         error:&internalError];
        NSLog(@"%@ %@", NSStringFromSelector(_cmd), internalError);
        
        migrated = [self reloadStore:newstore
                         withOptions:nil
                               error:&internalError];
        
    } else if(error){
        *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                     code:102
                                 userInfo:@{NSLocalizedDescriptionKey : @"iCloude disabled for current persistent store."}];
    }
    
    return migrated;
}

- (BOOL)reloadStore:(NSPersistentStore *)store withOptions:(NSDictionary *)options error:(NSError **)error {
    BOOL reloaded = NO;
    
    if (store && [self.persistentStoreCoordinator removePersistentStore:store error:error]) {
        NSPersistentStore *newstore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                    configuration:nil
                                                                                              URL:[self storeURL]
                                                                                          options:options
                                                                                            error:error];
        reloaded = newstore != NO;
    }
    return reloaded;
}

#pragma mark - Notification Observers

- (void)registerForiCloudNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self
                                  name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                object:self.persistentStoreCoordinator];
	
    [notificationCenter addObserver:self
                           selector:@selector(storesWillChange:)
                               name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter removeObserver:self
                                  name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(storesDidChange:)
                               name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                             object:self.persistentStoreCoordinator];
    
    [notificationCenter removeObserver:self
                                  name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                object:self.persistentStoreCoordinator];
    
    [notificationCenter addObserver:self
                           selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                               name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                             object:self.persistentStoreCoordinator];
}

- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification *)notification {
    NSManagedObjectContext *context = self.backgroundContext;
	NSLog(@"persistentStoreDidImportUbiquitousContentChanges : %@", notification);
    
    [context performBlock:^{
        [context mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (void)storesWillChange:(NSNotification *)notification {
    NSManagedObjectContext *context = self.mainContext;
	
    [context performBlockAndWait:^{
        NSError *error;
		
        if ([context hasChanges]) {
            BOOL success = [context save:&error];
            if (!success && error) {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        
        [context reset];
    }];
    
    NSNumber *ubiquitousTransitionType = [[notification userInfo] valueForKey:NSPersistentStoreUbiquitousTransitionTypeKey];
    NSLog(@"%@ NSPersistentStoreUbiquitousTransitionType = %@",NSStringFromSelector(_cmd), ubiquitousTransitionType);
    
    // Refresh your User Interface.
}

- (void)storesDidChange:(NSNotification *)notification {
    NSNumber *ubiquitousTransitionType = [[notification userInfo] valueForKey:NSPersistentStoreUbiquitousTransitionTypeKey];
    NSLog(@"%@ NSPersistentStoreUbiquitousTransitionType = %@",NSStringFromSelector(_cmd), ubiquitousTransitionType);
    
    // Refresh your User Interface.
}



@end
