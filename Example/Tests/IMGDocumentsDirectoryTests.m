//
//  IMGDocumentsDirectoryTests.m
//  ImageManagerTests
//
//  Created by Jason Ardell on 12/07/2015.
//  Copyright (c) 2015 Jason Ardell. All rights reserved.
//

#import "IMGDocumentsDirectory.h"
#import <XCTest/XCTest.h>

@import XCTest;

@interface IMGDocumentsDirectoryTests : XCTestCase

@end

@implementation IMGDocumentsDirectoryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSData *)inputData
{
    NSData *inputData = [@"Hello, world!" dataUsingEncoding:NSUTF8StringEncoding];
    return inputData;
}

- (NSString *)uri
{
    NSString *path = @"path/to/image.jpg";
    NSString *uri = [IMGDocumentsDirectory uriFromPath:path];
    return uri;
}

- (XCTestExpectation *)expectation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for async call to finish"];
    return expectation;
}

- (void)waitForExpectations
{
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError *error) {
        if (error) XCTFail(@"Async test timed out");
    }];
}

- (void)testThatDataRoundTripsToDocumentsDirectory
{
    XCTestExpectation *expectation = [self expectation];
    NSData *inputData = [self inputData];
    NSString *uri = [self uri];

    // Save data to documents directory
    [IMGDocumentsDirectory saveData:inputData toURI:uri]
        .then(^{
            // Load data from documents directory
            return [IMGDocumentsDirectory loadDataForURI:uri];
        })
        .then(^(NSData *outputData) {
            // Make sure that output matches input
            XCTAssert([outputData isEqualToData:inputData]);
            [expectation fulfill];
        })
        .catch(^(NSError *error) {
            XCTFail(@"Expected promise to resolve.");
        });
    [self waitForExpectations];
}

- (void)testThatDeleteFromURIDeletesExistingFile
{
    XCTestExpectation *expectation = [self expectation];
    NSData *inputData = [self inputData];
    NSString *uri = [self uri];

    // Save a file to URI
    [IMGDocumentsDirectory saveData:inputData toURI:uri]
        .then(^{
            // Call deleteFromURI (make sure promise resolves)
            return [IMGDocumentsDirectory deleteFromURI:uri];
        })
        .then(^{
            XCTAssertFalse((BOOL)[IMGDocumentsDirectory fileExistsAtURI:uri]);
            [expectation fulfill];
        })
        .catch(^(NSError *error) {
            XCTFail(@"Expected promise to resolve.");
        });
    [self waitForExpectations];
}

- (void)testThatDeleteFromURIResolvesIfFileDoesNotExist
{
    XCTestExpectation *expectation = [self expectation];
    NSString *uri = [self uri];

    // If file exists at URI, delete it
    if ([IMGDocumentsDirectory fileExistsAtURI:uri]) {
        [IMGDocumentsDirectory deleteFromURI:uri];
    }

    // Call deleteFromURI
    [IMGDocumentsDirectory deleteFromURI:uri]
        .then(^{
            // Expect promise to resolve
            [expectation fulfill];
        })
        .catch(^(NSError *error) {
            XCTFail(@"Expected promise to resolve.");
        });
    [self waitForExpectations];
}

@end

