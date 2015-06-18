//  Created by Alexander Skorulis on 24/07/2014.

@import CoreData;
#import "DataStackService.h"
#import <CollapsingFutures.h>

@interface DataStackService ()

@property (nonatomic, strong) NSString* databaseName;
@property (nonatomic, readonly) NSManagedObjectContext* writerContext;

@end

@implementation DataStackService

@synthesize mainContext = _mainContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize writerContext = _writerContext;

- (instancetype) initWithDBName:(NSString*)dbName clearDB:(BOOL)clearDB {
    self = [super init];
    _databaseName = dbName;
    if(clearDB) {
        [self deletePersistentStore];
    }
    [self persistentStoreCoordinator];
    return self;
}

- (NSManagedObjectContext*) writerContext {
    if(!_writerContext) {
        _writerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _writerContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _writerContext.mergePolicy = NSOverwriteMergePolicy;
    }
    return _writerContext;
}

- (NSManagedObjectContext*) mainContext {
    if(!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        //_mainContext.parentContext = self.writerContext;
        _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        _mainContext.mergePolicy = NSOverwriteMergePolicy; //AJS - not sure if I want to do this
    }
    return _mainContext;
}

- (NSManagedObjectContext*) temporaryContext {
    NSManagedObjectContext* temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.mainContext;
    return temporaryContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self databaseName] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
        [self createPersistentStore:TRUE];
    }
    
    return _persistentStoreCoordinator;
}

- (void) createPersistentStore:(BOOL)firstAttempt {
    NSURL *url = [[DataStackService applicationDocumentsDirectory] URLByAppendingPathComponent:[self databaseFilename]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
        
        if(firstAttempt && (error.code == 134100 || error.code == 134130)) {
            [self deletePersistentStore];
            [self createPersistentStore:FALSE];
        } else {
            NSLog(@"<core data>: Cannot handle error: %@, %@",error, [error userInfo]);
            abort();
        }
    } else {
        [self databaseCreated];
    }
}

- (NSURL*) persistentStoreURL {
    NSURL *storeURL = [[DataStackService applicationDocumentsDirectory] URLByAppendingPathComponent:[self databaseFilename]];
    return storeURL;
}

+ (NSString*) appDocumentsDirectoryPath {
    NSURL* url = [self applicationDocumentsDirectory];
    return [url.absoluteString substringFromIndex:7];
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) deletePersistentStore {
    NSURL *storeURL = [self persistentStoreURL];
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    [localFileManager removeItemAtURL:storeURL error:nil];
}

- (NSString*) databaseFilename {
    return [NSString stringWithFormat:@"%@.sqlite",[self databaseName]];
}

- (void) databaseCreated {
    //Empty method
}

- (TOCFuture*)saveMainToDisk {
    return [self saveToDiskFrom:self.mainContext];
}

- (TOCFuture*)saveToDiskFrom:(NSManagedObjectContext*)context {
    TOCFutureSource* futureSource = [[TOCFutureSource alloc] init];
    [self saveToDiskFrom:context futureSource:futureSource];
    return futureSource.future;
}

- (void) saveToDiskFrom:(NSManagedObjectContext*)context futureSource:(TOCFutureSource*)futureSource {
    __weak typeof(self) weakSelf = self;
    if(context == _writerContext) {
        [weakSelf.writerContext performBlock:^{
            [weakSelf saveContext:weakSelf.writerContext error:nil futureSource:futureSource];
        }];
    } else if(context == _mainContext) {
        [_mainContext performBlock:^{
            if([weakSelf saveContext:weakSelf.mainContext error:nil futureSource:nil]) {
                [weakSelf saveToDiskFrom:weakSelf.writerContext futureSource:futureSource];
            }
        }];
    } else {
        [context performBlock:^{
            if([weakSelf saveContext:context error:nil futureSource:nil]) {
                [weakSelf saveToDiskFrom:weakSelf.mainContext futureSource:futureSource];
            }
        }];
    }
}

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError __autoreleasing **)outError futureSource:(TOCFutureSource*)futureSource {
    NSError *error = nil;
    BOOL success = [context save:&error];
    if(success) {
        [futureSource trySetResult:@true];
    } else {
        if(outError != NULL) {
            *outError = error;
        }
        NSString* stack = [[NSThread callStackSymbols] componentsJoinedByString:@"\n"];
        NSString* s = [NSString stringWithFormat:@"---> <core data>: saving for context %@ failed.\n ---> Errors:\n%@ ---> Stack:\n%@", context, error,stack];
        NSLog(@"%@",s);
        [NSException raise:@"core data error" format:@"%@",s];
        [futureSource trySetFailure:error];
    }
    return success;
}

- (void) deleteAll:(NSEntityDescription*)entity context:(NSManagedObjectContext*)context {
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    fetch.entity = entity;
    fetch.includesPropertyValues = false;
    fetch.includesSubentities = false;
    
    NSError * error;
    NSArray * all = [context executeFetchRequest:fetch error:&error];
    if(error) {
        NSLog(@"Error deleting entities %@",entity);
        return;
    }
    
    for (NSManagedObject * obj in all) {
        [context deleteObject:obj];
    }

}


@end
