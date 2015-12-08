//
//  IMGImage.h
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import <Foundation/Foundation.h>
#import <PromiseKit/PromiseKit.h>

@interface IMGImage : NSObject

+ (PMKPromise *)loadDataForURI:(NSString *)uri;
+ (PMKPromise *)saveData:(NSData *)data
                   toURI:(NSString *)uri;
+ (PMKPromise *)deleteFromURI:(NSString *)uri;

@end
