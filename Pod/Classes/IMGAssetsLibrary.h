//
//  IMGAssetsLibrary.h
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>

@interface IMGAssetsLibrary : NSObject

+ (BOOL)matchesURI:(NSString *)uri;
+ (PMKPromise *)loadDataForURI:(NSString *)uri;
+ (PMKPromise *)saveData:(NSData *)data;

@end
