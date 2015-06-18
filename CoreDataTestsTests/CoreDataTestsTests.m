//
//  CoreDataTestsTests.m
//  CoreDataTestsTests
//
//  Created by Alexander Skorulis on 18/06/2015.
//  Copyright (c) 2015 com.skorulis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DataStackService.h"
#import "NumberEntity.h"

static const NSInteger count = 5000;

@interface CoreDataTestsTests : XCTestCase

@property (nonatomic, strong) DataStackService* service;

@end

@implementation CoreDataTestsTests

- (void)setUp {
    [super setUp];
    self.service = [[DataStackService alloc] initWithDBName:@"Model" clearDB:true];
}

- (void)testDatabaseWorking {
    XCTAssertNotNil(self.service.mainContext);
}

- (void)testBatchSaving {
    [self measureBlock:^{
        for(int i =0; i < count; ++i) {
            NumberEntity* e = [NumberEntity insertInManagedObjectContext:self.service.mainContext];
            e.value = @(i);
        }
        [self.service.mainContext save:nil];
    }];
    [self.service deleteAll:[NSEntityDescription entityForName:@"NumberEntity" inManagedObjectContext:self.service.mainContext] context:self.service.mainContext];
    [self.service.mainContext save:nil];
}

- (void) testIndividualSaving {
    [self measureBlock:^{
        for(int i =0; i < count; ++i) {
            NumberEntity* e = [NumberEntity insertInManagedObjectContext:self.service.mainContext];
            e.value = @(i);
            [self.service.mainContext save:nil];
        }
    }];
    [self.service deleteAll:[NSEntityDescription entityForName:@"NumberEntity" inManagedObjectContext:self.service.mainContext] context:self.service.mainContext];
    [self.service.mainContext save:nil];
}

@end
