//
//  IMGDocumentsDirectory.m
//  ImageManager
//
//  Created by Jason Ardell on 12/7/15.
//
//

#import "IMGDocumentsDirectory.h"

@implementation IMGDocumentsDirectory

+ (BOOL)matchesURI:(NSString *)uri
{
    NSRange range = [uri rangeOfString:@"documents-directory://"];
    return (range.location == 0);
}

+ (PMKPromise *)loadDataForURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        NSString *path = [IMGDocumentsDirectory _pathFromURI:uri];

        // Reject unless the file exists
        if (![IMGDocumentsDirectory _fileExistsAtPath:path]) {
            NSError *error = [NSError errorWithDomain:@"IMGDocumentsDirectory"
                                                 code:-1
                                             userInfo:nil];
            resolve(error);
            return;
        }

        // Load the data and resolve
        NSString *documentsDirectory = [[self class] _documentsDirectory];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        resolve(data);
    }];
}

+ (PMKPromise *)saveData:(NSData *)data
                   toURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        NSString *path = [IMGDocumentsDirectory _pathFromURI:uri];
        NSString *documentsDirectory = [[self class] _documentsDirectory];
        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
        [IMGDocumentsDirectory _ensureDirectoryExistsForPath:path];

        NSError *error;
        [data writeToFile:fullPath
                  options:NSDataWritingAtomic
                    error:&error];
        if (error) {
            resolve(error);
        } else {
            resolve(uri);
        }
    }];
}

+ (PMKPromise *)deleteFromURI:(NSString *)uri
{
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        NSString *path = [IMGDocumentsDirectory _pathFromURI:uri];

        // Resolve (nothing to do) if file doesn't exist
        if (![IMGDocumentsDirectory _fileExistsAtPath:path]) {
            resolve(nil);
            return;
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:path error:&error];
        resolve(error);
    }];
}

+ (NSString *)uriFromPath:(NSString *)path
{
    return [NSString stringWithFormat:@"documents-directory://root/%@", path];
}

+ (BOOL)fileExistsAtURI:(NSString *)uri
{
    NSString *path = [[self class] _pathFromURI:uri];
    NSString *documentsDirectory = [[self class] _documentsDirectory];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
}

#pragma Private methods

+ (NSString *)_pathFromURI:(NSString *)uri
{
    if (![[self class] matchesURI:uri]) return nil;

    NSURL *url = [NSURL URLWithString:uri];
    return [[url path] substringFromIndex:1];
}

+ (BOOL)_fileExistsAtPath:(NSString *)path
{
    NSString *uri = [[self class] uriFromPath:path];
    return [[self class] fileExistsAtURI:uri];
}

+ (void)_ensureDirectoryExistsForPath:(NSString *)path
{
    // Get the path to the directory containing the file in question
    NSString *uri = [self uriFromPath:path];
    NSURL *url = [NSURL URLWithString:uri];
    NSMutableArray *pathComponents = [[url pathComponents] mutableCopy];
    [pathComponents removeObjectAtIndex:0];  // slash at the beginning
    [pathComponents removeLastObject];  // the file path
    NSString *pathWithoutFile = [pathComponents componentsJoinedByString:@"/"];

    // Make sure it exists
    NSString *documentsDirectory = [[self class] _documentsDirectory];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:pathWithoutFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager fileExistsAtPath:fullPath]) {
        [fileManager createDirectoryAtPath:fullPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
}

+ (NSString *)_documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

@end
