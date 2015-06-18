// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NumberEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct NumberEntityAttributes {
	__unsafe_unretained NSString *value;
} NumberEntityAttributes;

extern const struct NumberEntityRelationships {
} NumberEntityRelationships;

extern const struct NumberEntityFetchedProperties {
} NumberEntityFetchedProperties;




@interface NumberEntityID : NSManagedObjectID {}
@end

@interface _NumberEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (NumberEntityID*)objectID;





@property (nonatomic, strong) NSNumber* value;



@property double valueValue;
- (double)valueValue;
- (void)setValueValue:(double)value_;

//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;






@end

@interface _NumberEntity (CoreDataGeneratedAccessors)

@end

@interface _NumberEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveValue;
- (void)setPrimitiveValue:(NSNumber*)value;

- (double)primitiveValueValue;
- (void)setPrimitiveValueValue:(double)value_;




@end
