//
//  IMGAssetsLibrary.m
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import "IMGAssetsLibrary.h"

@implementation IMGAssetsLibrary

+ (ALAssetsLibrary *)assetsLibrary
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    return library;
}

+ (BOOL)matchesURI:(NSString *)uri
{
    NSRange range = [uri rangeOfString:@"assets-library://"];
    return (range.location == 0);
}

+ (PMKPromise *)loadDataForURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        NSURL *url = [NSURL URLWithString:uri];
        ALAssetsLibrary *library = [[self class] assetsLibrary];
        [library assetForURL:url resultBlock:^(ALAsset *asset) {
            if (asset==nil) {
                NSError *error = nil;
                error = [NSError errorWithDomain:@"IMGAssetsLibrary" code:1 userInfo:nil];
                resolve(error);
                return;
            }

            // Load the image
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            CGImageRef imageRef = [representation fullResolutionImage];
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            resolve(data);
        }
        failureBlock:^(NSError *error) {
            resolve(error);
        }];
    }];
}

+ (PMKPromise *)saveData:(NSData *)data
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        ALAssetsLibrary *library = [[self class] assetsLibrary];
        [library writeImageDataToSavedPhotosAlbum:data
                                         metadata:@{}
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      if (error) {
                                          resolve(error);
                                      } else {
                                          resolve([assetURL absoluteString]);
                                      }
                                  }];
    }];
}

@end
