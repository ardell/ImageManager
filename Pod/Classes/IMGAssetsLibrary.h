//
//  IMGAssetsLibrary.h
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface IMGAssetsLibrary : NSObject

+ (ALAssetsLibrary *)assetsLibrary;  // Only public for testing

+ (BOOL)matchesURI:(NSString *)uri;
+ (PMKPromise *)loadDataForURI:(NSString *)uri;
+ (PMKPromise *)saveData:(NSData *)data;

@end
