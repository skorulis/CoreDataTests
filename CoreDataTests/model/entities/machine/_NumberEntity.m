// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to NumberEntity.m instead.

#import "_NumberEntity.h"

const struct NumberEntityAttributes NumberEntityAttributes = {
	.value = @"value",
};

const struct NumberEntityRelationships NumberEntityRelationships = {
};

const struct NumberEntityFetchedProperties NumberEntityFetchedProperties = {
};

@implementation NumberEntityID
@end

@implementation _NumberEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"NumberEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"NumberEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"NumberEntity" inManagedObjectContext:moc_];
}

- (NumberEntityID*)objectID {
	return (NumberEntityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"valueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"value"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic value;



- (double)valueValue {
	NSNumber *result = [self value];
	return [result doubleValue];
}

- (void)setValueValue:(double)value_ {
	[self setValue:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveValueValue {
	NSNumber *result = [self primitiveValue];
	return [result doubleValue];
}

- (void)setPrimitiveValueValue:(double)value_ {
	[self setPrimitiveValue:[NSNumber numberWithDouble:value_]];
}










@end
