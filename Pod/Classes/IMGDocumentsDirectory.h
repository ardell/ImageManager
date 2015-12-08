//
//  IMGDocumentsDirectory.h
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>

@interface IMGDocumentsDirectory : NSObject

+ (BOOL)matchesURI:(NSString *)uri;
+ (PMKPromise *)loadDataForURI:(NSString *)uri;
+ (PMKPromise *)saveData:(NSData *)data
                   toURI:(NSString *)uri;
+ (PMKPromise *)deleteFromURI:(NSString *)uri;
+ (NSString *)uriFromPath:(NSString *)path;
+ (BOOL)fileExistsAtURI:(NSString *)uri;

@end
