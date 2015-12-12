//
//  IMGAssetsLibraryTests.m
//  ImageManagerTests
//
//  Created by Jason Ardell on 12/11/2015.
//  Copyright (c) 2015 Jason Ardell. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <PromiseKit/Promise.h>
#import "IMGAssetsLibrary.h"

@import XCTest;

@interface IMGAssetsLibraryTests : XCTestCase

@end

@implementation IMGAssetsLibraryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)waitForExpectations
{
    [self waitForExpectationsWithTimeout:901.0 handler:^(NSError *error) {
        if (error) XCTFail(@"Async test timed out");
    }];
}

- (NSData *)inputData
{
    NSData *inputData = [@"Hello, world!" dataUsingEncoding:NSUTF8StringEncoding];
    return inputData;
}

- (void)testThatSaveDataResolvesToAURI
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for async call to finish"];
    NSData *inputData = [self inputData];

    // Stub out an instance of ALAssetsLibrary
    id library = [OCMockObject partialMockForObject:[[ALAssetsLibrary alloc] init]];
    NSURL *url = [NSURL URLWithString:@"assets-library://path/to/image.jpg"];
    void (^proxyBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        void (^passedBlock)(NSURL *assetURL, NSError *error);
        [invocation getArgument:&passedBlock atIndex:4];
        passedBlock(url, nil);
    };
    [[[library stub] andDo:proxyBlock] writeImageDataToSavedPhotosAlbum:[OCMArg any]
                                                               metadata:[OCMArg any]
                                                        completionBlock:[OCMArg any]];

    // Stub out [IMGAssetsLibrary assetsLibrary] to return our stub library
    id mock = [OCMockObject mockForClass:[IMGAssetsLibrary class]];
    [[[mock stub] andReturn:library] assetsLibrary];

    // Save data to assets library
    [IMGAssetsLibrary saveData:inputData]
        .then(^(NSString *uri) {
            XCTAssert([uri hasPrefix:@"assets-library://"]);
            [expectation fulfill];
        })
        .catch(^(NSError *error) {
            XCTFail(@"Expected promise to resolve.");
        });
    [self waitForExpectations];
}

//- (void)testThatLoadDataForURILoadsNSData
//{
//    // Save data to assets library (and note the returned URI)
//    // Load data from the saved URI
//}

@end
