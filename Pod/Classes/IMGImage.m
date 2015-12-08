//
//  IMGImage.m
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import "IMGImage.h"
#import "IMGAssetsLibrary.h"
#import "IMGDocumentsDirectory.h"

@implementation IMGImage

+ (PMKPromise *)loadDataForURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        if ([IMGAssetsLibrary matchesURI:uri]) {
            // Load data from assets library
            [IMGAssetsLibrary loadDataForURI:uri]
                .then(^(NSData *data) { resolve(data); })
                .catch(^(NSError *error) { resolve(error); });
        } else if ([IMGDocumentsDirectory matchesURI:uri]) {
            // Load data from documents directory
            [IMGDocumentsDirectory loadDataForURI:uri]
                .then(^(NSData *data) { resolve(data); })
                .catch(^(NSError *error) { resolve(error); });
        } else {
            // Reject promise
            NSError *error = [[NSError alloc] initWithDomain:@"IMGImage"
                                                        code:-1
                                                    userInfo:nil];
            resolve(error);
        }
    }];
}

+ (PMKPromise *)saveData:(NSData *)data
                   toURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        if ([IMGAssetsLibrary matchesURI:uri]) {
            // Save to assets library and resolve with actual URI
            [IMGAssetsLibrary saveData:data]
                .then(^(NSURL *url) { resolve([url absoluteString]); })
                .catch(^(NSError *error) { resolve(error); });
        } else if ([IMGDocumentsDirectory matchesURI:uri]) {
            // Save to #{documents dir}/#{path} and return uri
            [IMGDocumentsDirectory saveData:data toURI:uri]
                .then(^(NSURL *url) { resolve(uri); })
                .catch(^(NSError *error) { resolve(error); });
        } else {
            // Reject promise
            NSError *error = [[NSError alloc] initWithDomain:@"IMGImage"
                                                        code:-1
                                                    userInfo:nil];
            resolve(error);
        }
    }];
}

+ (PMKPromise *)deleteFromURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        // NOTE: ALAssetsLibrary doesn't allow deletion
        if ([IMGDocumentsDirectory matchesURI:uri]) {
            // Delete file at uri
            [IMGDocumentsDirectory deleteFromURI:uri]
                .then(^(NSURL *url) { resolve(uri); })
                .catch(^(NSError *error) { resolve(error); });
        } else {
            // Reject promise
            NSError *error = [[NSError alloc] initWithDomain:@"IMGImage"
                                                        code:-1
                                                    userInfo:nil];
            resolve(error);
        }
    }];
}

@end
