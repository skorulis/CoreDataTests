//  Created by Alexander Skorulis on 24/07/2014.

@import Foundation;
@import CoreData;

@class TOCFuture;

@interface DataStackService : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;

- (NSManagedObjectContext *)temporaryContext;
- (TOCFuture*)saveMainToDisk;
- (instancetype) initWithDBName:(NSString*)dbName clearDB:(BOOL)clearDB;
- (void) deleteAll:(NSEntityDescription*)entity context:(NSManagedObjectContext*)context;

@end
